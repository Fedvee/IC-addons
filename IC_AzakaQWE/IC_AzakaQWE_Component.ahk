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
Gui, ICScriptHub:Add, Text, x15 y+15, Ult. on this many Contracts Fulfilled:
Gui, ICScriptHub:Add, Edit, vAzakaQWE_Contracts x+5 w50, % g_AzakaQWESettings.NumContracts
Gui, ICScriptHub:Add, Text, x+5 vAzakaQWE_Contracts_Saved w200, % "Saved value: " . g_AzakaQWESettings.NumContracts

if ( g_AzakaQWESettings.Loops == "" )
    g_AzakaQWESettings.Loops := 5
Gui, ICScriptHub:Add, Text, x15 y+15, Ult. this many times:
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

if ( g_AzakaQWESettings.SwapWDurationSecs == "" )
    g_AzakaQWESettings.SwapWDurationSecs := 0
Gui, ICScriptHub:Add, Text, x15 y+15, Swap to W for this many seconds after ults:
Gui, ICScriptHub:Add, Edit, vAzakaQWE_SwapWDurationSecs x+5 w50, % g_AzakaQWESettings.SwapWDurationSecs
Gui, ICScriptHub:Add, Text, x+5 vAzakaQWE_SwapWDurationSecs_Saved w200, % "Saved value: " . g_AzakaQWESettings.SwapWDurationSecs

Gui, ICScriptHub:Add, Button, x15 y+10 w160 gAzakaQWE_Save, Save Settings
Gui, ICScriptHub:Add, Button, x15 y+10 w160 gAzakaQWE_Run, Run

Gui, ICScriptHub:Add, Text, x15 y+10 vAzakaQWE_Running w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_CurrentContracts w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_CurrentUltStatus w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_UltsUsed w300,
Gui, ICScriptHub:Add, Text, x15 y+5 vAzakaQWE_popping w300,

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

    g_AzakaQWESettings.SwapWDurationSecs := AzakaQWE_SwapWDurationSecs
    GuiControl, ICScriptHub:, AzakaQWE_SwapWDurationSecs_Saved, % "Saved value: " . g_AzakaQWESettings.SwapWDurationSecs

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
    guiData.guiControlIDpopping := "AzakaQWE_popping"
    guiData.guiControlIDults := "AzakaQWE_UltsUsed"

    azaka := new AzakaQWEFarm(g_AzakaQWESettings, guiData)
    azaka.Run()

    GuiControl, ICScriptHub:, AzakaQWE_Running, Azaka farm is complete.
    GuiControl, ICScriptHub:, AzakaQWE_CurrentContracts,
    GuiControl, ICScriptHub:, AzakaQWE_CurrentUltStatus,
    GuiControl, ICScriptHub:, AzakaQWE_UltsUsed,
    GuiControl, ICScriptHub:, AzakaQWE_popping,
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
            if (settings.Ult[A_Index] AND A_Index < 10)
                this.inputs.Push(A_Index . "")
            else if (settings.Ult[A_Index] AND A_Index == 10)
                this.inputs.Push(0 . "")

            if (settings.Ult[A_Index])
                this.ultIndexes.Push(A_Index - 1)
        }
        this.loops := settings.Loops
        this.numContracts := settings.NumContracts
        this.swapWDurationSecs := g_AzakaQWESettings.SwapWDurationSecs
        if IsObject(guiData)
        {
            this.useGUI := true
            this.guiName := guiData.guiName
            this.guiControlIDcont := guiData.guiControlIDcont
            this.guiControlIDultStatus := guiData.guiControlIDultStatus
            this.guiControlIDpopping := guiData.guiControlIDpopping
            this.guiControlIDults := guiData.guiControlIDults
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
            wait := true
            while wait
            {
                if this.farm()
                    wait := false
                sleep, 100
            }
            if (this.useGUI)
                GuiControl, % this.guiName, % this.guiControlIDults, % "Ultimates Used: " . A_Index
        }
    }

    farm()
    {
        g_SF.Memory.ActiveEffectKeyHandler.Refresh()
        num := ActiveEffectKeySharedFunctions.Omin.OminContractualObligationsHandler.ReadNumContractsFulfilled()
	num := max(num,0)

	if (this.useGUI)
            GuiControl, % this.guiName, % this.guiControlIDcont, % "Current No. Contracts Fulfilled: " . num

	allUltsReady := this.areAllUltsReady()
	if (this.useGUI) {
	    GuiControl, % this.guiName, % this.guiControlIDultStatus, % "Ults Status: " . ((allUltsReady) ? "READY" : "On Cooldown")
	}

	allUltsOnCD := this.areAllUltsOnCooldown()

	if (this.useGUI)
            GuiControl, % this.guiName, % this.guiControlIDpopping, % "popping ults: " . this.popping

	if (!this.popping AND (num < this.numContracts)) {
 	    g_SF.DirectedInput(,,["{q}"]*)	    
	    sleep, (this.numContracts - num) * 20
	    return false
	}

	if (!this.popping AND (num >= this.numContracts) AND !allUltsReady) {
	    g_SF.DirectedInput(,,["{e}"]*)
	    return false
	}

	if (!this.popping AND (num >= this.numContracts) AND allUltsReady) {
	    this.popping := 1
 	    g_SF.DirectedInput(,, this.inputs*)
 	    g_SF.DirectedInput(,,["{q}"]*)
	    return false
	}
	if (this.popping AND !allUltsOnCD) {
	    g_SF.DirectedInput(,, this.inputs*)
 	    g_SF.DirectedInput(,,["{q}"]*)
	    return false
	}

	if (this.popping AND allUltsOnCD) {
	    this.popping := 0
	    if (this.swapWDurationSecs > 0) {
 	        g_SF.DirectedInput(,,["{w}"]*)
		sleep, this.swapWDurationSecs * 1000
 		g_SF.DirectedInput(,,["{q}"]*)
	    }
	return true
	}
    }

    areAllUltsReady()
    {
        For index, value in this.ultIndexes
        {
            ultCd := this.readUltimateCooldownByItem(value)
            if (ultCd > 0)
                return false ; any ult cd > 0 means they aren't all ready
        }
        return true
    }

    areAllUltsOnCooldown()
    {
        For index, value in this.ultIndexes
        {
            ultCd := this.readUltimateCooldownByItem(value)
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
