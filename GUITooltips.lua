function GUITooltip_ExtraDuties()

	local PlayerID = GUI.GetPlayerID()
	if PlayerID == BS.SpectatorPID then
		PlayerID = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
	end
	local TaxAmount = Logic.GetPlayerTaxIncome(PlayerID)
	local TaxBonus = 1

	for i = 1, gvVStatue3.Amount[PlayerID] do
		TaxBonus = TaxBonus + (math.max(gvVStatue3.BaseValue - (i - 1) * gvVStatue3.DecreaseValue, gvVStatue3.MinimumValue))
	end
	local TaxName = ""
	local TextString = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		TaxName = "Taler"
		TextString = "@color:180,180,180,255 Sonderabgaben  @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Steuereintreibung  @cr @color:255,204,51,255 ermöglicht: @color:255,255,255,255  Verlangt Sonderabgaben von Euren Siedlern. Das füllt Euren Staatssäckel, jedoch werden Eure Arbeiter nicht sonderlich begeistert sein und ihre Motivation wird sinken."
	else
		TaxName = "Thalers"
		TextString = "@color:180,180,180,255 Levy Taxes  @cr @color:255,204,51,255 requires: @color:255,255,255,255 Taxation  @cr @color:255,204,51,255 allows: @color:255,255,255,255  Demand special taxes from your settlers. That fills your state purse, but your workers will not be very enthusiastic and their motivation will decrease."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TextString)
 	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "@color:255,255,255,255 "..TaxName.." : ".. round(TaxAmount * TaxBonus))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, " ")

end
function GUITooltip_Outpost_Serf()
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Kauft einen Leibeigenen @cr @color:255,255,255,255  Ein Lebeigener sammelt Ressourcen, baut und repariert Häuser und kann die Gegend erkunden. Er braucht kein Haus und keinen Bauernhof! ")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 50")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end

function GUITooltip_ActivateAlarm()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Alarm @cr @color:255,204,51,255 Alle Arbeiter fliehen in das Haupthaus, die Dorfzentren und die Werkstätten und beschießen die Feinde." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, " " )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Outpost_VeryLowTaxes()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Keine Steuern @cr @color:255,255,255,255 Eure Arbeiter zahlen keine Steuern. Das wird sie SEHR glücklich machen, doch Ihr müsst Euch überlegen wie Ihr zu Geld kommt." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, " " )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Outpost_LowTaxes()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Niedrige Steuern @cr @color:255,255,255,255 Bei niedrigen Steuern müsst Ihr knapper kalkulieren. Aber dafür steigt jeden Monat auch die Motivation der Arbeiter." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, " " )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Outpost_NormalTaxes()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Moderate Steuern @cr @color:255,255,255,255 Ein guter Kompromiss zwischen Euch und Euren Arbeitern. Niemand wird sich darüber beschweren." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, " " )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Outpost_HighTaxes()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Hohe Steuern @cr @color:255,255,255,255 Hohe Steuern füllen Euren Staatssäckel zwar schneller, allerdings sinkt mit jedem Zahltag auch die Motivation der Arbeiter." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, " " )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Outpost_VeryHighTaxes()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Sehr hohe Steuern @cr @color:255,255,255,255 Eure Arbeiter werden sich nicht darüber freuen, dass Ihr ihnen das letzte Hemd auszieht. Doch Eure Schatzkammern werden sich schnell füllen." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, " " )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_LightningRod()
	local TooltipName = ""
	local TooltipCosts = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		TooltipName = "@color:180,180,180 Blitzableiter @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Der Blitzableiter sorgt dafür, dass Eure Siedlung kurzzeitig immun gegen Blitzeinschläge ist!"
		TooltipCosts = "@color:255,255,255,255 Eisen: 600 @cr Schwefel: 400"
	else
		TooltipName = "@color:180,180,180 Lightning Rod @cr @color:255,204,51,255 requires: @color:255,255,255,255 @cr 	@color:255,204,51,255 allows: @color:255,255,255,255 The lightning rod makes your buildings temporarily immune to thunder strikes."
		TooltipCosts = "@color:255,255,255,255 Iron: 600 @cr Sulfur: 400"
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,TooltipName)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,TooltipCosts)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_MakeThunderStorm()
	local TooltipName = ""
	local TooltipCosts = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
	TooltipName = "@color:180,180,180 Unwetter @cr @color:255,255,255,255 Eure Ingenieure wechseln das Wetter zum Unwetter, sobald Sie die Maschine komplett ausgerichtet haben!"
	else
	TooltipName = "@color:180,180,180 Thunder Storm @cr @color:255,255,255,255 Your engineers change the weather to thunder storm as soon as they completed their work."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,TooltipName)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,TooltipCosts)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_UpgradeLighthouse()
	local TooltipName = ""
	local TooltipCosts = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		TooltipName = "@color:180,180,180 Ausbau zum Leuchtturm @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Stattet den Leuchtturm mit einem entzündeten Leuchtfeuer aus. So könnt ihr Verstärkungen anfordern."
		TooltipCosts = "@color:255,255,255,255 Taler: 200 @cr Holz: 500"
	else
		TooltipName = "@color:180,180,180 Expansion to a lighthouse @cr @color:255,204,51,255 requires: @color:255,255,255,255 @cr 	@color:255,204,51,255 allows: @color:255,255,255,255 Equip the lighthouse with a lighted beacon. So you can request reinforcements."
		TooltipCosts = "@color:255,255,255,255 Thalers: 200 @cr Wood: 500"
	end
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText,TooltipName)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,TooltipCosts)
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_LighthouseHireTroops()
	local TooltipCosts = ""
	local TooltipName = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		TooltipCosts = "@color:255,255,255,255 Eisen: 600 @cr Schwefel: 400"
		TooltipName = "@color:180,180,180 Verstärkungen anfordern @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Leuchtturm @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Fordert Verstärkungstruppen an."
	else
		TooltipCosts = "@color:255,255,255,255 Iron: 600 @cr Sulfur: 400"
		TooltipName = "@color:180,180,180 Request reinforcements @cr @color:255,204,51,255 requires: @color:255,255,255,255 Lighthouse @cr 	@color:255,204,51,255 allows: @color:255,255,255,255 Call in reinforcements."
	end
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText,TooltipName)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,TooltipCosts)
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end

function GUITooltip_ResourceSilver()
	local CostString = " "
	local ShortCutToolTip = " "
	local TooltipText = " "
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		TooltipText = "@color:180,180,180 Silber @cr @color:255,255,255,255 Diese Menge Silber steht Euch im Moment zur Verfügung."
	else
		TooltipText = "@color:180,180,180 Silver @cr @color:255,255,255,255 This amount of silver is currently available to you."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_ResourceFaith()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Glaube @cr @color:255,255,255,255 Dieser Prozentsatz Glaube steht Euch im Moment zur Verfügung."
	else
		Text = "@color:180,180,180 Faith @cr @color:255,255,255,255 That percentage of faith is available to you right now."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_ResourceWeatherEnergy()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Wetterenergie @cr @color:255,255,255,255 Dieser Prozentsatz Wetterenergie steht Euch im Moment zur Verfügung."
	else
		Text = "@color:180,180,180 Weather energy @cr @color:255,255,255,255 This percentage of weather energy is available to you at the moment."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_ResourceCoal()
	local CostString = " "
	local ShortCutToolTip = " "
	local TooltipText = " "
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		TooltipText = "@color:180,180,180 Kohle @cr @color:255,255,255,255 Diese Menge Kohle steht Euch im Moment zur Verfügung."
	else
		TooltipText = "@color:180,180,180 Coal @cr @color:255,255,255,255 This amount of coal is currently available to you."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DetailedResourceView()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Erweiterte Ressourcen-Anzeige @cr @color:255,255,255,255 Klickt hier, um Euch Details zu Euren Ressourcen anzeigen zu lassen."
	else
		Text = "@color:180,180,180 Extended resource display @cr @color:255,255,255,255 Click here to view details about your resources."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_NormalResourceView()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Normale Ressourcen-Anzeige @cr @color:255,255,255,255 Klickt hier, um zur normalen Ressourcen-Anzeige zurück zu kehren."
	else
		Text = "@color:180,180,180 Normal resource display @cr @color:255,255,255,255 Click here to return to the normal resource display."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_RPGView()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 RPG-Sichtmodus @cr @color:255,255,255,255 Klickt hier, um zum RPG-Sichtmodus zu wechseln."
	else
		Text = "@color:180,180,180 RPG view mode @cr @color:255,255,255,255 Click here to switch to RPG view mode."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DownView()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Draufsicht-Modus @cr @color:255,255,255,255 Klickt hier, um zur Draufsicht zu wechseln."
	else
		Text = "@color:180,180,180 Top view mode @cr @color:255,255,255,255 Click here to switch to the top view."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_NormalView()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 normaler Sichtmodus @cr @color:255,255,255,255 Klickt hier, um zum normalen Sichtmodus zu wechseln."
	else
		Text = "@color:180,180,180 normal viewing mode @cr @color:255,255,255,255 Click here to switch to normal viewing mode."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_Time()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 aktuelle Uhrzeit @cr @color:255,255,255,255 Hier wird die aktuelle Uhrzeit des Spiels angezeigt. @cr Sonnenaufgang: 06:00 Uhr @cr Sonnenuntergang: 20:00 Uhr"
	else
		Text = "@color:180,180,180 current time @cr @color:255,255,255,255 The current time of the game is displayed here. @cr Sunrise: 6:00 AM @cr Sunset: 8:00 PM"
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DetailsLeader()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Erweiterte Stats-Anzeige @cr @color:255,255,255,255 Klickt hier, um Euch Details zur Stärke Eurer Soldaten anzeigen zu lassen."
	else
		Text = "@color:180,180,180 Extended stats display @cr @color:255,255,255,255 Click here for details on the strength of your soldiers."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DetailsLeaderOff()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Normale Stats-Anzeige @cr @color:255,255,255,255 Klickt hier, um zur normalen Anzeige zurück zu kehren."
	else
		Text = "@color:180,180,180 Normal stats display @cr @color:255,255,255,255 Click here to return to the normal display."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_ExpelAll()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Massenentlassung @cr @color:255,255,255,255 Klickt hier, um alle selektierten Einheiten zu entlassen."
		ShortCutToolTip = "Taste: [Y]"
	else
		Text = "@color:180,180,180 Mass layoffs @cr @color:255,255,255,255 Click here to dismiss all selected units."
		ShortCutToolTip = "Key: [Y]"
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_AttackRange()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Angriffsreichweite @cr @color:255,255,255,255 Dies zeigt die aktuelle Angriffsreichweite dieser Einheit an."
	else
		Text = "@color:180,180,180 Attack range @cr @color:255,255,255,255 This indicates the current attack range of this unit."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_VisionRange()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Sichtreichweite @cr @color:255,255,255,255 Dies zeigt die aktuelle Sichtreichweite dieser Einheit an."
	else
		Text = "@color:180,180,180 View range @cr @color:255,255,255,255 This shows the current visual range of this unit."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_AttackSpeed()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Angriffstempo @cr @color:255,255,255,255 Dies zeigt das aktuelle Angriffstempo dieser Einheit an (in Angriffe pro Sekunde)"
	else
		Text = "@color:180,180,180 Attack speed @cr @color:255,255,255,255 This shows the current attack speed of this unit (in attacks per second)"
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_MoveSpeed()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Lauftempo @cr @color:255,255,255,255 Dies zeigt das aktuelle Lauftempo dieser Einheit an."
	else
		Text = "@color:180,180,180 Movement speed @cr @color:255,255,255,255 This shows the current movement speed of this unit."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_Experience()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""
	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Erfahrungspunkte @cr @color:255,255,255,255 Dies zeigt die aktuellen Erfahrungspunkte dieser Einheit an."
	else
		Text = "@color:180,180,180 Experience points @cr @color:255,255,255,255 This shows the current experience points of this unit."
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_AOFindHero()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local EntityID = XGUIEng.GetBaseWidgetUserVariable(CurrentWidgetID, 0)

	local CostString = " "
	local ShortCutToolTip = " "
	local TooltipString = " "

	if EntityID  ~= 0 then
		if Logic.IsEntityInCategory(EntityID,EntityCategories.Hero10) == 1 then
			TooltipString = "AOMenuTop/Find_hero10"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero11) == 1 then
			TooltipString = "AOMenuTop/Find_hero11"
		elseif Logic.GetEntityType( EntityID )	== Entities.CU_Evil_Queen then
			TooltipString = "AOMenuTop/Find_hero12"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero13) == 1 then
			TooltipString = "AOMenuTop/Find_hero13"
		else
			GUITooltip_FindHero()
			return
		end
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end

function GUITooltip_Archers_Tower_AddSlot()

	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""

	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Truppen einlagern @cr @color:255,255,255,255 Klickt hier, um ein nahestehendes Trupp Schützen den Turm hochklettern zu lassen."
	else
		Text = "@color:180,180,180 Fill with troops @cr @color:255,255,255,255 Click here to let nearby bowman or rifleman climb up the tower."
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

end

function GUITooltip_Archers_Tower_RemoveSlot()

	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""

	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Truppen auslagern @cr @color:255,255,255,255 Klickt hier, um ein stationiertes Trupp den Turm herunterklettern zu lassen."
	else
		Text = "@color:180,180,180 Outsource troops @cr @color:255,255,255,255 Click here to let a occupied troop climb down the tower."
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

end

function GUITooltip_Archers_Tower_Slot(_slot)

	local CostString = " "
	local ShortCutToolTip = " "
	local Text = ""

	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Truppenslot ".._slot.." @cr @color:255,255,255,255 Klickt hier, um dieses Trupp den Turm herunterklettern zu lassen."
	else
		Text = "@color:180,180,180 troop slot ".._slot.." @cr @color:255,255,255,255 Click here to let this troop climb down the tower."
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

end
-- Army Creator Tooltips
function GUITooltip_ArmyCreator(_name,_modifier)

	local pretext
	if _modifier > 0 then
		if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
			pretext = "Erhöht die Anzahl von"
		else
			pretext = "Increases the amount of"
		end
	elseif _modifier < 0 then
		if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
			pretext = "Reduziert die Anzahl von"
		else
			pretext = "Decreases the amount of"
		end
	end
	local String = XGUIEng.GetStringTableText("names/".._name)
	XGUIEng.SetText("BS_ArmyCreator_Tooltip", " @center "..pretext.." " .. string.gsub(String, " @bs ", " "))

end
function GUITooltip_AOFindHero()

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	local EntityID = XGUIEng.GetBaseWidgetUserVariable(CurrentWidgetID, 0)

	local CostString = " "
	local ShortCutToolTip = " "
	local TooltipString = " "

	if EntityID  ~= 0 then
		if Logic.IsEntityInCategory(EntityID,EntityCategories.Hero10) == 1 then
			TooltipString = "AOMenuTop/Find_hero10"
		elseif Logic.IsEntityInCategory(EntityID,EntityCategories.Hero11) == 1 then
			TooltipString = "AOMenuTop/Find_hero11"
		elseif Logic.GetEntityType( EntityID )	== Entities.CU_Evil_Queen then
			TooltipString = "AOMenuTop/Find_hero12"
		elseif Logic.GetEntityType( EntityID )	== Entities.PU_Hero13 then
			TooltipString = "AOMenuTop/Find_hero13"
		elseif Logic.GetEntityType( EntityID )	== Entities.PU_Hero14 then
			TooltipString = "AOMenuTop/Find_hero14"
		else
			GUITooltip_FindHero()
			return
		end
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_Forester_PauseWork()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = " "

	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Arbeit pausieren @cr @color:255,255,255,255 Klickt hier, um den Förster seine Arbeit niederlegen zu lassen."
	else
		Text = "@color:180,180,180 pause work @cr @color:255,255,255,255 Click here to make the forester stop working."
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_Forester_StartWork()
	local CostString = " "
	local ShortCutToolTip = " "
	local Text = " "

	if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) == "de" then
		Text = "@color:180,180,180 Arbeit wieder aufnehmen @cr @color:255,255,255,255 Klickt hier, um den Förster seine Arbeit wieder aufnehmen zu lassen."
	else
		Text = "@color:180,180,180 resume work @cr @color:255,255,255,255 Click here to have the forester resume his work."
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Text)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_BuyMilitaryUnit(_EntityType, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut, _BuildingType)

	local PlayerID = GUI.GetPlayerID()
	Logic.FillLeaderCostsTable(PlayerID, _EntityType + 2 ^ 16, InterfaceGlobals.CostTable)
	local SelectedBuildingType = Logic.GetEntityType(GUI.GetSelectedEntity())
	local UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(_BuildingType)
	local EntityTypes = {Logic.GetBuildingTypesInUpgradeCategory(UpgradeCategory)}
	local PositionOfSelectedEntityInTable, PositionOfNeededEntityInTable = 0, 0
	local CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable)
	local TooltipText = _NormalTooltip
	local NeededPlaces = Logic.GetAttractionLimitValueByEntityType(_EntityType)
	local ShortCutToolTip = " "

	for i = 1, EntityTypes[1] do
		if EntityTypes[i+1] == SelectedBuildingType then
			PositionOfSelectedEntityInTable = i + 1
		end
		if EntityTypes[i+1] == _BuildingType then
			PositionOfNeededEntityInTable = i + 1
		end
	end

	CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NamePlaces") .. ": " .. NeededPlaces

	if _TechnologyType ~= nil then
		local TechState = Logic.GetTechnologyState(PlayerID, _TechnologyType)
		if TechState == 0 then
			TooltipText =  "MenuGeneric/UnitNotAvailable"
			CostString = " "
		elseif TechState == 1 or TechState == 5 or PositionOfNeededEntityInTable > PositionOfSelectedEntityInTable then
			TooltipText = _DisabledTooltip
		end
	end

	if _ShortCut ~= nil then
		ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

end
function GUITooltip_BuyMerc(_UpgradeCategory, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut)

	local PlayerID = GUI.GetPlayerID()
	local SettlerTypeID = Logic.GetSettlerTypeByUpgradeCategory(_UpgradeCategory, PlayerID)
	Logic.FillLeaderCostsTable(PlayerID, _UpgradeCategory, InterfaceGlobals.CostTable)
	local CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable)
	local TooltipText = _NormalTooltip
	local NeededPlaces = Logic.GetAttractionLimitValueByEntityType(SettlerTypeID)
	local ShortCutToolTip = " "

	CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NamePlaces") .. ": " .. NeededPlaces

	if _TechnologyType ~= nil then
		local TechState = Logic.GetTechnologyState(PlayerID, _TechnologyType)
		if TechState == 0 then
			TooltipText =  "MenuGeneric/UnitNotAvailable"
			CostString = " "
		elseif TechState == 1 then
			TooltipText = _DisabledTooltip
		end
	end

	if _ShortCut ~= nil then
		ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
--------------------------------------------------------------------------------
-- Display Text and costs for a buy soldiers button
--------------------------------------------------------------------------------
function GUITooltip_BuySoldier(_NormalTooltip, _DisabledTooltip, _ShortCut)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()

	local LeaderID = GUI.GetSelectedEntity()
	local PlayerID = GUI.GetPlayerID()

	local etype = Logic.LeaderGetSoldiersType(LeaderID)
	Logic.FillSoldierCostsTable(PlayerID, etype + 2 ^ 16, InterfaceGlobals.CostTable)
	local CostString = InterfaceTool_CreateCostString(InterfaceGlobals.CostTable)
	local ShortCutToolTip = " "

	if XGUIEng.IsButtonDisabled(CurrentWidgetID) == 1 then
		TooltipText =  _DisabledTooltip
	elseif XGUIEng.IsButtonDisabled(CurrentWidgetID) == 0 then
		TooltipText = _NormalTooltip
	end

	if _ShortCut ~= nil then
		ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

end
function GUITooltip_UpgradeLeader(_LeaderID, _ShortCut)
	local PlayerID = GUI.GetPlayerID()
	local entities = {GUI.GetSelectedEntities()}
	local etype, upetype, numsoldiers, soletype, upsoletype, t, CostString, TooltipText
	if not entities[2] then
		etype = Logic.GetEntityType(_LeaderID)
		upetype = etype + 1
		numsoldiers = Logic.LeaderGetNumberOfSoldiers(_LeaderID)
		soletype = Logic.LeaderGetSoldiersType(_LeaderID)
		upsoletype = soletype + 1
		t = CreateCostDifferenceTable(PlayerID, etype, upetype, soletype, upsoletype, numsoldiers)
		CostString = InterfaceTool_CreateCostString(t)
		TooltipText = "Wertet diesen Hauptmann und alle seine Soldaten auf!"
		if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) ~= "de" then
			TooltipText = "Upgrade this leader and all his soldiers!"
		end
	else
		local temp_t = {}
		for i = 1, table.getn(entities) do
			local id = entities[i]
			if Logic.IsLeader(id) == 1 then
				etype = Logic.GetEntityType(id)
				local tech = UpgradeTechByEtype[etype]
				if tech then
					local techstate = Logic.GetTechnologyState(PlayerID, tech)
					if techstate == 4 and Logic.LeaderGetNearbyBarracks(id) ~= 0 then
						upetype = etype + 1
						numsoldiers = Logic.LeaderGetNumberOfSoldiers(id)
						soletype = Logic.LeaderGetSoldiersType(id)
						upsoletype = soletype + 1
						temp_t[i] = CreateCostDifferenceTable(PlayerID, etype, upetype, soletype, upsoletype, numsoldiers)
					end
				end
			end
		end
		t = {}
		for i = 1, 17 do
			t[i] = 0
		end
		for k, v in pairs(temp_t) do
			for i = 1, table.getn(v) do
				t[i] = t[i] + v[i]
			end
		end
		CostString = InterfaceTool_CreateCostString(t)
		TooltipText = "Wertet alle selektierten Hauptmänner und alle ihre Soldaten auf! @cr Dies gilt für alle Hauptmänner, die sich nahe ihres Militärgebäudes befinden und deren erforderliche Technologie für das Upgrade erforscht ist."
		if string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName()) ~= "de" then
			TooltipText = "Upgrades all selected leaders and all their soldiers! @cr This applies to all leaders that are near their military building and have researched the technology required for the upgrade."
		end
	end
	local ShortCutToolTip = ""
	if _ShortCut ~= nil then
		ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

end

function GUITooltip_Hero13_JudgmentBonus()
	local player = GUI.GetPlayerID()
	if player == BS.SpectatorPID then
		player = Logic.EntityGetPlayer(GUI.GetSelectedEntity())
	end
	local tooltip = XGUIEng.GetStringTableText("MenuHero13/command_divinejudgmentbonus")
	local bonusttip = ""
	local bonusdmg = round(gvHero13.AbilityProperties.DivineJudgment.Judgment.DamageFactorBonus[player] * 100)
	local bonusrange = round(gvHero13.AbilityProperties.DivineJudgment.Judgment.RangeFactorBonus[player] * 100)
	if bonusdmg > 0 then
		bonusttip = "Schadensbonus: " .. bonusdmg .. "% @cr Reichweitenbonus: " .. bonusrange .. "%"
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, tooltip)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, bonusttip)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "")
end

function GUITooltip_Hero9_Plunder()
	local hero = GUI.GetSelectedEntity()
	local tooltip = XGUIEng.GetStringTableText("MenuHero9/command_plunder")
	local CostString = ""
	local tab = gvHero9.AbilityProperties.Plunder
	if tab.Plundered[hero] then
		CostString = gvHero9.CreatePlunderedResDataString(tab.Plundered[hero])
	end
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, tooltip)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, "")
end