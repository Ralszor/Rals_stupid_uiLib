---@class BattlePK : Object
local BattlePK, super = Class(Object)

function BattlePK:init()
    super.init(self)
    self.state = "BATTLE_PKMN"
    self.selected_x = 1
    self.selected_y = 1
    self.con = 0
    self.timer = Timer()
    self:addChild(self.timer)
    self.music = Music()
    --self.encounter = nil
end

function BattlePK:postInit(transition, encounter)
    super.postInit(self, transition, encounter)
       if type(encounter) == "string" then
        self.encounter = Registry.createEncounter(encounter)
    else
        self.encounter = encounter
    end
    
    self.music:play(self.encounter.music)
    self.timer:script(function (wait)
        local a 
        Game.fader:fadeIn(function () a = 1 end, {alpha = 1, color = COLORS.black})
        wait(16/30)
        Game.fader:fadeIn(function () a = 2 end, {alpha = 1, color = COLORS.black})
        wait(16 / 30)
        Game.fader:fadeIn(function () a = 1 end, {alpha = 1, color = COLORS.black})
        wait(16 / 30)
        local sq = Rectangle(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 2, 2)
        sq:setOrigin(0.5)
        sq:setColor(COLORS.black)
        sq:setParallax(0)
        sq.layer = 9999
        Game.world:addChild(sq)
        self.timer:tween(1, sq, {scale_x = 320, scale_y = 240})
        wait(1.25)
        Game.world.encountering_enemy = false
        Game.lock_movement = false
        self.con = 1
        sq:remove()
    end)
end

function BattlePK:draw()
    super.draw(self)
    if self.con == 0 then return end
    Draw.setColor(COLORS.white)
    Draw.rectangle("fill", 0,0,999,999)
end

function BattlePK:update()
    super.update(self)
end

function BattlePK:isWorldHidden()
    return self.con > 0
end

function BattlePK:onKeyPressed(key)
    if Input.is("up", key) then
        Assets.playSound("ui_move")
        self.selected_y = MathUtils.clamp(self.selected_y - 1, 1, 3)
    end

    if Input.is("down", key) then
        Assets.playSound("ui_move")
        self.selected_y = MathUtils.clamp(self.selected_y + 1, 1, 3)
    end

    if Input.is("left", key) then
        Assets.playSound("ui_move")
        self.selected_x = MathUtils.clamp(self.selected_x - 1, 1, 2)
    end

    if Input.is("right", key) then
        Assets.playSound("ui_move")
        self.selected_x = MathUtils.clamp(self.selected_x + 1, 1, 2)
    end
    
end

return BattlePK