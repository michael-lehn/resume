-- firstfit.lua -- first-fit line breaking for justified paragraphs
--
-- Pages (like most word processors) breaks lines greedily: each line takes as
-- many words as fit at their natural width, and the line is then justified.
-- TeX instead optimizes the breaks of the whole paragraph, which gives
-- different line breaks. To reproduce the Pages layout, this filter chooses
-- the first-fit break points and inserts forced breaks there before TeX's
-- line breaker runs. Each forced line is still justified by TeX.
--
-- Break opportunities are interword glue and explicit hyphens (as in
-- "cache-aware"); the document disables automatic hyphenation.
--
-- Usage: \directlua{dofile(kpse.find_file("firstfit.lua", "lua"))}

local GLYPH  = node.id("glyph")
local GLUE   = node.id("glue")
local KERN   = node.id("kern")
local PENALTY = node.id("penalty")
local DISC   = node.id("disc")
local HLIST  = node.id("hlist")
local VLIST  = node.id("vlist")
local RULE   = node.id("rule")
local MATH   = node.id("math")

local EPS = 1 -- tolerance in sp for rounding

local function natural_width(n)
  local id = n.id
  if id == GLYPH or id == HLIST or id == VLIST or id == RULE then
    return n.width
  elseif id == KERN then
    return n.kern
  elseif id == GLUE then
    return n.width
  elseif id == MATH then
    return n.surround or 0
  elseif id == DISC then
    return n.replace and node.dimensions(n.replace) or 0
  end
  return 0
end

local function discardable(n)
  local id = n.id
  return id == GLUE or id == KERN or id == PENALTY or id == MATH
end

-- Width available for the lines of this paragraph (all lines are assumed to
-- have the same width, which holds for this document).
local function line_width()
  local w = tex.hsize - tex.leftskip.width - tex.rightskip.width
  local ps = tex.parshape
  if ps and type(ps) == "table" and #ps > 0 then
    w = ps[1][2] - tex.leftskip.width - tex.rightskip.width
  end
  return w
end

-- Pages breaks after a hyphen that follows a lowercase letter ("cache-aware",
-- "quantum-memory") but not after an uppercase one ("LLVM-based").
-- (LuaTeX keeps the hyphen either before the discretionary or inside it.)
local function hyphen_after_lowercase(disc)
  local c = disc.prev
  if not disc.replace and c and c.id == GLYPH then c = c.prev end
  return c and c.id == GLYPH and c.char >= 0x61 and c.char <= 0x7A
end

local function first_fit(head)
  local width = line_width()
  local used = 0            -- natural width of the current line so far
  local last_break = nil    -- last feasible break node in the current line
  local line_start = true   -- skipping discardable items after a break
  local prev = nil
  local n = head
  while n do
    local id = n.id
    local nextn = n.next
    if line_start and discardable(n) and prev ~= nil then
      -- glue and penalties at the start of a line vanish after a break
    else
      if prev ~= nil then line_start = false end
      local feasible =
        (id == GLUE and prev and not discardable(prev)) or
        (id == DISC and (n.subtype == 1 or n.subtype == 2)
                    and hyphen_after_lowercase(n))
      if feasible then
        -- width up to (not including) this break
        if used <= width + EPS then
          last_break = n
        elseif last_break then
          -- break at the previous feasible point and restart there
          local p = node.new(PENALTY)
          p.penalty = -10000
          if last_break.id == DISC then
            node.insert_after(head, last_break, p)
          else
            node.insert_before(head, last_break, p)
          end
          -- re-measure the material after the chosen break
          used = 0
          line_start = true
          local m = (last_break.id == DISC) and p.next or last_break
          last_break = nil
          prev = p
          while m ~= n do
            if not (line_start and discardable(m)) then
              line_start = false
              used = used + natural_width(m)
            end
            m = m.next
          end
          if not line_start and used <= width + EPS then
            last_break = n
          end
        end
      end
      if not (line_start and discardable(n) and prev ~= nil) then
        used = used + natural_width(n)
      end
    end
    prev = n
    n = nextn
  end
  -- final segment: if the last line overflows, break at its last opportunity
  if used > width + EPS and last_break then
    local p = node.new(PENALTY)
    p.penalty = -10000
    if last_break.id == DISC then
      node.insert_after(head, last_break, p)
    else
      node.insert_before(head, last_break, p)
    end
  end
  return head
end

luatexbase.add_to_callback("pre_linebreak_filter", function(head, groupcode)
  if groupcode == "" or groupcode == "vbox" or groupcode == "vtop"
     or groupcode == "insert" then
    return first_fit(head)
  end
  return head
end, "firstfit")
