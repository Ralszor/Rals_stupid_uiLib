local ChaserEnemy, super = HookSystem.hookScript(ChaserEnemy)

function ChaserEnemy:init(actor, x, y, properties)
    super.init(self, actor, x, y, properties)
    self.type = properties["type"] or "normal" --"pokemon"
end

function ChaserEnemy:onCollide(player)
    if self.type == "normal" then return super.onCollide(self, player) end

    if self:isActive() and player:includes(Player) then
        self.encountered = true

        if not self.encounter then
            error("ChaserEnemy has no encounter set!")
        end

        self.world.encountering_enemy = true
        self.sprite:setAnimation("hurt")
        self.sprite.aura = false
        Game.lock_movement = true
        self.world.timer:script(function(wait)
            local enemy_target = self ---@type ChaserEnemy|table[]
            if self.enemy then
                enemy_target = { { self.enemy, self } }
            end
            Game:encounterPK(self.encounter, true, enemy_target, self)
        end)
    end
end

return ChaserEnemy