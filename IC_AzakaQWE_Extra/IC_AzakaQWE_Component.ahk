GUIFunctions.AddTab("AzakaQWE")

global g_AzakaQWESettings := g_SF.LoadObjectFromJSON( A_LineFile . "\..\Settings.json" )
if !IsObject(g_AzakaQWESettings)
    g_AzakaQWESettings := {}

Gui, ICScriptHub:Tab, AzakaQWE
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, Text, x15 y80, AzakaQWE
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, x15 y+5, This AddOn will use the configured ults at a set Omin number of contracts fulfilled.
Gui, ICScriptHub:Add, Text, x15 y+5, Ults will only be triggered when all ultimates are off cooldown.
Gui, ICScriptHub:Add, Text, x15 y+5, If configured, once all ults have been triggered the W formation will activated for
Gui, ICScriptHub:Add, Text, x15 y+5, the configured amount of time before swapping back to Q.

if ( g_AzakaQWESettings.NumContracts == "" )
    g_AzakaQWESettings.NumContracts := 95
Gui, ICScriptHub:Add, Text, x15 y+15, Ult on this many contracts fulfilled (suggestion: 0 for Mehen, 97 for Omin)
Gui, ICScriptHub:Add, Edit, vAzakaQWE_Contracts x+5 w50, % g_AzakaQWESettings.NumContracts
Gui, ICScriptHub:Add, Text, x+5 vAzakaQWE_Contracts_Saved w200, % "Saved value: " . g_AzakaQWESettings.NumContracts

if ( g_AzakaQWESettings.Loops == "" )
    g_AzakaQWESettings.Loops := 5
Gui, ICScriptHub:Add, Text, x15 y+15, Ult this many times (suggestion: 1 for event/TG/Tiamat, 7 for main campaigns) :
Gui, ICScriptHub:Add, Edit, vAzakaQWE_Loops x+5 w50, % g_AzakaQWESettings.Loops
Gui, ICScriptHub:Add, Text, x+5 vAzakaQWE_Loops_Saved w200, % "Saved value: " . g_AzakaQWESettings.Loops

if ( g_AzakaQWESettings.Ult == "" )
{
    g_AzakaQWESettings.Ult := {}
    loop, 10
    {
        g_AzakaQWESettings.Ult[A_Index] := 0
    }
}

Gui, ICScriptHub:Add, Text, x15 y+15, Use the following ultimates:
loop, 10
{
    chk := g_AzakaQWESettings.Ult[A_Index]
    Gui, ICScriptHub:Add, Checkbox, vAzakaQWE_CB%A_Index% Checked%chk% x15 y+10, % A_Index
    Gui, ICScriptHub:Add, Text, x+5 vAzakaQWE_CB%A_Index%_Saved w200, % chk == 1 ? "Saved value: Checked":"Saved value: Unchecked"
}

if ( g_AzakaQWESettings.msPerContract == "" )
    g_AzakaQWESettings.msPerContract := 0
Gui, ICScriptHub:Add, Text, x15 y+15, milliseconds per contract (higher reduces lag, lower reduces mistakes):
Gui, ICScriptHub:Add, Edit, vAzakaQWE_msPerContract x+5 w50, % g_AzakaQWESettings.msPerContract
Gui, ICScriptHub:Add, Text, x+5 vAzakaQWE_msPerContract_Saved w200, % "Saved value: " . g_AzakaQWESettings.msPerContract

Gui, ICScriptHub:Add, Button, x15 y+10 w160 gAzakaQWE_Save, Save Settings
Gui, ICScriptHub:Add, Button, x15 y+10 w160 gAzakaQWE_Run, Run

Gui, ICScriptHub:Add, Text, x15 y+10 vAzakaQWE_Running w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_CurrentContracts w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_CurrentUltStatus w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_UltsUsed w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_debug w300,

AzakaQWE_Save()
{
    global
    Gui, ICScriptHub:Submit, NoHide
    g_AzakaQWESettings.NumContracts := AzakaQWE_Contracts
    GuiControl, ICScriptHub:, AzakaQWE_Contracts_Saved, % "Saved value: " . g_AzakaQWESettings.NumContracts

    g_AzakaQWESettings.Loops := AzakaQWE_Loops
    GuiControl, ICScriptHub:, AzakaQWE_Loops_Saved, % "Saved value: " . g_AzakaQWESettings.Loops

    loop, 10
    {
        g_AzakaQWESettings.Ult[A_Index] := AzakaQWE_CB%A_Index%
        GuiControl, ICScriptHub:, AzakaQWE_CB%A_Index%_Saved, % AzakaQWE_CB%A_Index% == 1 ? "Saved value: Checked":"Saved value: Unchecked"
    }

    g_AzakaQWESettings.msPerContract := AzakaQWE_msPerContract
    GuiControl, ICScriptHub:, AzakaQWE_msPerContract_Saved, % "Saved value: " . g_AzakaQWESettings.msPerContract

    g_SF.WriteObjectToJSON(A_LineFile . "\..\Settings.json" , g_AzakaQWESettings)
}

AzakaQWE_Run()
{
    GuiControl, ICScriptHub:, AzakaQWE_Running, Azaka farm is running.
    ;initialize shared functions for memory reads and directed inputs
    g_SF.Hwnd := WinExist("ahk_exe " . g_UserSettings[ "ExeName" ])
    g_SF.Memory.OpenProcessReader()

    OutputDebug, % g_SF.Memory.GameManager.game.gameInstances.Screen.uiController.ultimatesBar.ultimateItems.ultimateAttack

    ;create object for azaka class to update gui
    guiData := {}
    guiData.guiName := "ICScriptHub:"
    guiData.guiControlIDcont := "AzakaQWE_CurrentContracts"
    guiData.guiControlIDultStatus := "AzakaQWE_CurrentUltStatus"
    guiData.guiControlIDults := "AzakaQWE_UltsUsed"
    guiData.guiControlIDdebug := "AzakaQWE_debug"

    azaka := new AzakaQWEFarm(g_AzakaQWESettings, guiData)
    azaka.Run()

    GuiControl, ICScriptHub:, AzakaQWE_Running, Azaka farm is complete.
    GuiControl, ICScriptHub:, AzakaQWE_CurrentContracts,
    GuiControl, ICScriptHub:, AzakaQWE_CurrentUltStatus,
    GuiControl, ICScriptHub:, AzakaQWE_UltsUsed,
    GuiControl, ICScriptHub:, AzakaQWE_debug,
    msgbox, Azaka farm is complete.
}

class AzakaQWEFarm
{
    ultIndexes := []
    inputs := {}
    loops := {}
    useGUI := false

    __new(settings, guiData)
    {
        loop, 10
        {
            if (settings.Ult[A_Index]) {
	        ultKey := mod(A_Index,10)    
                this.inputs.Push(ultKey . "")
                this.ultIndexes.Push(A_Index - 1)
	    }
	    this.AzakaUltKey := ultKey ; this works because Azaka is in the last seat. If CNE moves Azaka or creates a 13th seat changes may be needed
        }
        this.loops := settings.Loops
        this.numContracts := settings.NumContracts
        this.msPerContract := g_AzakaQWESettings.msPerContract
        if IsObject(guiData)
        {
            this.useGUI := true
            this.guiName := guiData.guiName
            this.guiControlIDcont := guiData.guiControlIDcont
            this.guiControlIDultStatus := guiData.guiControlIDultStatus
            this.guiControlIDults := guiData.guiControlIDults
            this.guiControlIDdebug := guiData.guiControlIDdebug
        }
        return this
    }

    Run()
    {
        if (this.useGUI)
            GuiControl, % this.guiName, % this.guiControlIDults, % "Ultimates Used: 0"
	this.popping := 0
        loops := this.Loops
        loop, %loops%
        {
	    while !this.farm() {
	        sleep 100
	    }
            if (this.useGUI)
                GuiControl, % this.guiName, % this.guiControlIDults, % "Ultimates Used: " . A_Index
        }
    }

    farm()
    {
        g_SF.Memory.ActiveEffectKeyHandler.Refresh()
	this.oldnum := this.num
        this.num := ActiveEffectKeySharedFunctions.Omin.OminContractualObligationsHandler.ReadNumContractsFulfilled()
	if ((this.num == "") OR (this.num < 0)) {
	    this.num := 0
	}
	if (this.oldnum == "") {
	    this.oldnum := this.num
        }

	if (this.useGUI)
            GuiControl, % this.guiName, % this.guiControlIDcont, % "Contracts Fulfilled: " . this.num

	allUltsReady := this.areAllUltsReady()
	if (this.useGUI) {
	    GuiControl, % this.guiName, % this.guiControlIDultStatus, % "Ults Status: " . ((allUltsReady) ? "READY" : "On Cooldown")
	}

	allUltsOnCD := this.areAllUltsOnCooldown()

 	this.AzakaCD := this.readUltimateCooldownByItem(this.AzakaUltKey)
 	if (this.useGUI) {
 	    GuiControl, % this.guiName, % this.guiControlIDdebug, % "Azaka CD: " . this.AzakaCD
	}

	; Five mutually exclusive and exhaustive cases are considered below

	if (!this.popping AND (this.num < this.numContracts)) { ; wait for contracts to be fulfilled
	    if (this.oldnum == this.num) {
 	        g_SF.DirectedInput(,,["{q}"]*)
	    }
	    if (this.num <= this.numContracts - 3) {
	        sleep, max(0, (this.numContracts - this.num) * this.msPerContract * 3/4 - 100)
	    }
	    return false
	}	

	if (!this.popping AND !(this.num < this.numContracts) AND !allUltsReady) { ; swap out Omin
	    if (this.numContracts > 0) { ; don't swap to E formation for Mehen
		if (this.oldnum != this.num) {
		    g_SF.DirectedInput(,,["{e}"]*)
		}
	    }
	    return false
	}

	if (!this.popping AND !(this.num < this.numContracts) AND allUltsReady) { ; start popping ultimates
	    this.popping := 1
 	    g_SF.DirectedInput(,, this.inputs*)
	    if (this.oldnum == this.num) {
 	        g_SF.DirectedInput(,,["{q}"]*)
	    }
	    return false
	}
	
	if (this.popping AND !allUltsOnCD) { ; continue popping ultimates
	    g_SF.DirectedInput(,, this.inputs*)
	    if (this.oldnum == this.num) {
 	        g_SF.DirectedInput(,,["{q}"]*)
	    }
	    return false
	}

	if (this.popping AND allUltsOnCD) { ; swap in Gazrick, wait for Azaka's ultimate to end, and then swap in Freely
	    this.popping := 0
	    g_SF.DirectedInput(,,["{w}"]*)
	    this.AzakaCD := this.readUltimateCooldownByItem(this.AzakaUltKey)
	    if (this.useGUI)
		GuiControl, % this.guiName, % this.guiControlIDdebug, % "Azaka CD: " . this.AzakaCD
	    while (this.AzakaCD > 65.0) {
		sleep, max(1, this.AzakaCD - 65.0) * 100
		this.AzakaCD := this.readUltimateCooldownByItem(this.AzakaUltKey)
		if (this.useGUI)
		    GuiControl, % this.guiName, % this.guiControlIDdebug, % "Azaka CD: " . this.AzakaCD
	    }
	    g_SF.DirectedInput(,,["{q}"]*)
	    return true
	}
    }

    areAllUltsReady()
    {
        For index, ultkey in this.ultIndexes
        {
            ultCd := this.readUltimateCooldownByItem(ultkey)
            if (ultCd > 0)
                return false ; any ult cd > 0 means they aren't all ready
        }
        return true
    }

    areAllUltsOnCooldown()
    {
        For index, ultkey in this.ultIndexes
        {
            ultCd := this.readUltimateCooldownByItem(ultkey)
            if (ultCd <= 0)
                return false ; any ult cd <= 0 means it's not on cd
        }
        return true
    }

    ; TODO: Temp while this isn't in scripthub proper
    readUltimateCooldownByItem(item := 0)
    {
        return g_SF.Memory.GameManager.game.gameInstances[g_SF.Memory.GameInstance].Screen.uiController.ultimatesBar.ultimateItems[item].ultimateAttack.CooldownTimer.Read()
    }
}
