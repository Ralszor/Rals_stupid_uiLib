---@class BattlePK : Object
local BattlePK, super = Class(Object)

function BattlePK:init()
    super.init(self)
    self.state = "BATTLE_PKMN"
    self.selected_x = 1
    self.selected_y = 1
    self.con = 0
    self.enemies = {}
    self.enemies_index = {}
    self.player_sprite = nil
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

    self:applyPokemonEnemySprites()
    self:createPlayerSprite()

    if Game.world.music:isPlaying() and self.encounter.music then
        self.resume_world_music = true
        Game.world.music:pause()
    end

    if self.encounter.music then
        self.music:play(self.encounter.music)
    end

    self.timer:script(function (wait)
        local a 
        Game.fader:fadeIn(function () a = 1 end, {speed = 0.4, alpha = 1, color = COLORS.black})
        wait(0.4)
        Game.fader:fadeIn(function () a = 2 end, {speed = 0.4, alpha = 1, color = COLORS.black})
        wait(0.4)
        Game.fader:fadeIn(function () a = 1 end, {speed = 0.4, alpha = 1, color = COLORS.black})
        wait(0.4)
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
        self:startPokemonIntro()
    end)
end

function BattlePK:draw()
    if self.con == 0 then return end
    Draw.setColor(COLORS.white)
    Draw.rectangle("fill", 0,0,999,999)
    super.draw(self)
end

function BattlePK:update()
    super.update(self)
end

function BattlePK:setBattleSprite(sprite, primary, fallback)
    if sprite:hasSprite(primary) then
        sprite:setSprite(primary)
        return true
    end

    if fallback and sprite:hasSprite(fallback) then
        sprite:setSprite(fallback)
        return true
    end

    return false
end

function BattlePK:applyPokemonEnemySprites()
    for _, enemy in ipairs(self.enemies) do
        if enemy.sprite and not self:setBattleSprite(enemy.sprite, "battle/pokemon/front", "battle/pokemon") then
            enemy:resetSprite()
        end
    end
end

function BattlePK:createPlayerSprite()
    local party_member = Game.party and Game.party[1]
    if not party_member then
        return
    end

    local actor = party_member:getActor()
    if not actor then
        return
    end

    self.player_sprite = actor:createSprite()
    self.player_sprite:setScale(4)
    self.player_sprite:setOrigin(0, 1)

    if not self:setBattleSprite(self.player_sprite, "battle/pokemon/back", "battle/pokemon") then
        if self.player_sprite:hasSprite("battle/idle") then
            self.player_sprite:setSprite("battle/idle")
        else
            self.player_sprite:resetSprite()
        end
    end

    self:addChild(self.player_sprite)
end

function BattlePK:startPokemonIntro()
    local enemy_x = SCREEN_WIDTH - 150
    local enemy_y = 180
    local enemy =  self.enemies[1]
    enemy:setPosition(-120, enemy_y)
    self.timer:tween(2, enemy, {x = SCREEN_WIDTH - 80})

    if self.player_sprite then
        self.player_sprite:setPosition(SCREEN_WIDTH + 120, SCREEN_HEIGHT - 60)
        self.timer:tween(2, self.player_sprite, {x = 40})
    end
end

function BattlePK:isHighlighted(battler)
    return false
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
