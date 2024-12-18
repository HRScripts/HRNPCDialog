---@class HRNPCDialgueConfig
---@field turnOff { minimap: boolean, playerVisibility: boolean }
---@field transitionDuration number
---@field themeColor { r: number<255>, g: number<255>, b: number<255> }

---@class HRNPCDialogueOptions
---@field npcName string
---@field questions { label: string, possibleAnswers: { label: string, closeOnSelect: boolean?, onSelect: function? }[] }[]
---@field onCancel function?