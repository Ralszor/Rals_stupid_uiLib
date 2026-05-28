local Game, super = HookSystem.hookScript(Game)

function Game:encounterPK(encounter, transition, enemy, context)
    if transition == nil then transition = true end

    Assets.playSound("splat")

    if self.battle then
        error("Attempt to enter battle while already in battle")
    end

    if enemy and not isClass(enemy) then
        self.encounter_enemies = enemy
    else
        self.encounter_enemies = {enemy}
    end

    self.state = "BATTLE"

    self.battle = BattlePK()

    if context then
        self.battle.encounter_context = context
    end

    if type(transition) == "string" then
        self.battle:postInit(transition, encounter)
    else
        self.battle:postInit(transition and "TRANSITION" or "INTRO", encounter)
    end

    self.stage:addChild(self.battle)
end

return Game