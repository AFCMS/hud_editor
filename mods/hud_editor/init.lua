local vector = vector
local string = string
local sf = string.format

if not minetest.is_singleplayer() then error("Cannot be used in multiplayer") end

-- ORIGIN --

minetest.register_node("hud_editor:origin", {
	drawtype = "airlike",
	walkable = true,
	pointable = false,
	diggable = false,
	is_ground_content = false,
	drop = "",
	groups = { not_in_creative_inventory = 1, immortal = 1 },
})

local origin_pos = vector.new(0, -1, 0)

local box_positions = {
	vector.new(0, -1, 0),
	vector.new(1, 0, 0),
	vector.new(1, 1, 0),
	vector.new(-1, 0, 0),
	vector.new(-1, 1, 0),
	vector.new(0, 0, 1),
	vector.new(0, 1, 1),
	vector.new(0, 0, -1),
	vector.new(0, 1, -1),
	vector.new(0, 2, 0),
}

minetest.register_on_generated(function(minp, maxp, seed)
	local blockpos = origin_pos
	if (minp.x <= blockpos.x and
		maxp.x >= blockpos.x and
		minp.y <= blockpos.y and
		maxp.y >= blockpos.y and
		minp.z <= blockpos.z and
		maxp.z >= blockpos.z) then

		minetest.bulk_set_node(box_positions, {name = "hud_editor:origin"})
		minetest.log("action", "[hud_editor] origin has been set at "..minetest.pos_to_string(blockpos)..".")
	end
end)

local cached_player
local hud_defs = {}
local hud_ids = {}
local hud_id_selected = 1

local function update_huds()
	if cached_player then
		for _,rm_id in ipairs(hud_ids) do
			cached_player:hud_remove(rm_id)
		end

		hud_ids = {}

		for id,def in ipairs(hud_defs) do
			table.insert(hud_ids, cached_player:hud_add({
				hud_elem_type = def.hud_elem_type,
				position = def.position,
				name = tostring(id),
				scale = def.scale,
				text = def.text,
				text2 = def.text2,
				number = def.number,
				item = def.item,
				direction = def.direction,
			}))
		end
	end
end

local function build_formspec()
	local out = table.concat({
		"formspec_version[4]",
		"size[20,12]",
		"button[7,10;12,1;refresh;Refresh]",
		sf("textlist[1,1;5,10;hud_list;<listelem 1>,<listelem 2>,...,<listelem n>;%s;false]", hud_id_selected),
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.refresh then
		update_huds()
	elseif fields then
	end
end)


minetest.register_on_joinplayer(function(player, last_login)
	cached_player = player
end)