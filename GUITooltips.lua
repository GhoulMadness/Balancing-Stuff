function GUITooltip_ExtraDuties()
				
	local PlayerID = GUI.GetPlayerID()
	local TaxAmount = Logic.GetPlayerTaxIncome( PlayerID )
	local TextString = "@color:180,180,180,255 Sonderabgaben  @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Steuereintreibung  @cr @color:255,204,51,255 ermöglicht: @color:255,255,255,255  Verlangt Sonderabgaben von Euren Siedlern. Das füllt Euren Staatssäckel, jedoch werden Eure Arbeiter nicht sonderlich begeistert sein und ihre Motivation wird sinken."
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TextString)
 	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "@color:255,255,255,255 Steuereinnahmen: "..TaxAmount)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Outpost_Serf()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Kauft einen Leibeigenen @cr @color:255,255,255,255  Ein Lebeigener sammelt Ressourcen, baut und repariert Häuser und kann die Gegend erkunden. Er braucht kein Haus und keinen Bauernhof! ")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 50")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
--[[deprecated: not used anymore; now defined in the respective string-tables
function GUITooltip_Taxation()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Steuereintreibung @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Festung, Bildung @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Die Steuereintreibung ermöglicht das Erheben von Zusatzsteuern!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 100")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Banking()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Bankwesen @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Steuereintreibung, Universität @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Das Bankwesen ermöglicht den Bau von Banken, um Eure Taler zu vermehren!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 500")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Laws()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Gesetzbücher @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Bankwesen, Zitadelle @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Die Gesetzbücher ermöglichen den Ausbau der Bank zur Schatzkammer sowie den Bau von  Au\195\159enposten!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 300 @cr Schwefel: 100")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Gilds()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Schatzmeistergilden @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Gesetzbücher, mindestens 20 Forschungen an der Uni @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Die Schatzmeistergilden ermöglichen den Ausbau der Schatzkammer zur Münzstätte!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 700")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_TownGuard()
	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Bessere Studien @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Stadtzentrum, Universität, Hochwertige Schuhe @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Durch bessere Studien wird die Forschungsdauer reduziert!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 400 ")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_PickAxe()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Spitzhacke @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Lehmbergwerk @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Die Spitzhacke ermöglicht Euren Bergwerken, effektiver zu arbeiten!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Lehm: 800")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")	
end
function GUITooltip_LightBricks()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Verbesserte Ziegel @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Ziegelbrennerei @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Dank der Verbesserten Ziegel könnt ihr Eure Gebäude schneller bauen!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 200 @cr Lehm: 400 @cr Holz: 100")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Debenture()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Schuldscheine @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Schatzkammer @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Stellt Schuldscheine aus und erhöht so die Zahltag-Frequenz.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 300")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Coinage()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Münzprägung @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Münzstätte, Maß @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Effizienteren Handel durch Münzprägung.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 300 @cr Eisen: 400")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Scale()
	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Maß @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Schatzkammer @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Erforscht das Maß um den Warentausch am Markt zu verbessern.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 200 @cr Holz: 50")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_BookKeeping()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Buchhaltung @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Münzstätte, Schuldscheine @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255  Die Buchhaltung ermöglicht Euch, Taler effektiver zu vermehren!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 400")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Printing()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Buchdruck @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Handelswesen, Universität @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Uhr. Ausbau von Kapellen!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 200 @cr Eisen: 200")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_Library()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Büchereien @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Buchdruck, Zitadelle, Universität @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Teleskop. Ausbau von Kirchen!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 500 @cr Holz: 300")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_UpgradeBank1()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Ausbau zur Schatzkammer @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Gesetzbücher @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Baut Eure Bank mit einem sicheren Tresor aus und macht sie zur Schatzkammer!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 200 @cr Steine: 300")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end
function GUITooltip_UpgradeBank2()

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Ausbau zur Münzstätte @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Schatzmeistergilden @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Bessere Veredlung von Talern sowie die Erforschung von Buchhaltung und Münzprägung!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 600 @cr Steine: 800")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut," ")
end

function GUITooltip_Built_Bank()
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Bank @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Bankwesen @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Verzinsung der Stadtkasse!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Holz: 500 @cr Steine: 500")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut,"  ")
end
function GUITooltip_Built_Outpost()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Au\195\159enposten @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Gesetzbücher  @cr @color:255,204,51,255 ermöglicht: @color:255,255,255,255 Errichtet einen Au\195\159enposten an der angegebenen Stelle. Er funktioniert wie eine Burg. Erweitert Euer Siedlerlimit zudem um 30 Pl\195\164tze." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, "Holz: 8000 @cr Stein: 8000  @cr Lehm: 8000" )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Built_Mercenary()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 S\195\182ldnerturm @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Taktiken @cr @color:255,204,51,255 ermöglicht: @color:255,255,255,255 Anwerben von S\195\182ldnern aus fernen Landen." )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, "Holz: 400 @cr Stein: 400 " )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end 
function GUITooltip_Built_Lighthouse()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Leuchtturm @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Fernglas, Architektur @cr @color:255,204,51,255 ermöglicht: @color:255,255,255,255 Der Leuchtturm verf\195\188gt \195\188ber die h\195\182chste Sichtreichweite aller Gebäude. Später könnt Ihr hier Signalfeuer entzünden, um Verstärkungen anzufordern. Muss auf einem Leuchtturm-Fundament platziert werden!" )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, "Holz: 500 @cr Stein: 2000 @cr Lehm: 300" )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Built_Weathermachine()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Wettermaschine @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Wettervorhersage, Chemie @cr @color:255,204,51,255 ermöglicht: @color:255,255,255,255 Die Wettermaschine ermöglicht Forschungen zur Manipulation von Unwettern!" )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, "Holz: 200 @cr Stein: 600 @cr Schwefel: 600" )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_Built_Dome()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Dom @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Alle Technologien in der Uni @cr @color:255,204,51,255 ermöglicht: @color:255,255,255,255 Wer einen fertig gebauten Dom zu seiner Stadt zählen kann, ist wahrlich gesegnet. Wenn der Dom mindestens 10 Minuten lang steht, hat das Team das Spiel automatisch gewonnen!" )
    XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomCosts, "Stein: 100000 @cr Silber: 2000" )
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_ThunderStorm()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Unwettererforschung @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Wetterwechsel auf Unwetter, um mehr Blitzeinschläge zu provozieren!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 300 @cr Schwefel: 300")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_HeavyThunder()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Schweres Unwetter @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Unwettererforschung @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Mehr Blitzeinschläge beim Unwetter!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 500 @cr Schwefel: 500")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_TotalDestruction()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Zerstörerische Wetterphänomene @cr @color:255,204,51,255 benötigt: @color:255,255,255,255  @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Blitzeinschläge fügen mehr Schaden an Gebäuden zu!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Eisen: 400 @cr Schwefel: 200")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_LightningInsurance()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Blitzschlag-Versicherung @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Zerstörerische Wetterphänomene @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Wenn eines Eurer Gebäude vom Blitz getroffen wird, erhaltet ihr abhängig vom Schaden am Gebäude Taler!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 700 ")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
]]
function GUITooltip_UpgradeMarket2()
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText,"@color:180,180,180,255 Ausbau zum Handelsposten @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Münzprägung @cr 			@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Schnelleren Handel")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 200 @cr Steine: 300 @cr Holz: 150 @cr Lehm: 100")
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
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Blitzableiter @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Der Blitzableiter sorgt dafür, dass Eure Siedlung kurzzeitig immun gegen Blitzeinschläge ist!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Eisen: 600 @cr Schwefel: 400")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MakeThunderStorm()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Unwetter @cr @color:255,255,255,255 Eure Ingenieure wechseln das Wetter zum Unwetter, sobald Sie die Maschine komplett ausgerichtet haben!")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts," ")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_UpgradeLighthouse()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Ausbau zum Leuchtturm @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Stattet den Leuchtturm mit einem entzündeten Leuchtfeuer aus. So könnt ihr Verstärkungen anfordern.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 200 @cr Holz: 500")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_LighthouseHireTroops()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Verstärkungen anfordern @cr @color:255,204,51,255 benötigt: @color:255,255,255,255 Leuchtturm @cr 	@color:255,204,51,255 ermöglicht: @color:255,255,255,255 Fordert Verstärkungstruppen an.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Eisen: 600 @cr Schwefel: 400")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerRecruitBarbarian()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BuyLeaderBarbarian_disabled"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 160 @cr Eisen: 55 @cr Holz: 20")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerRecruitBanditSword()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BuyLeaderBanditSword_disabled"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 160 @cr Eisen: 85")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerRecruitBanditBow()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BuyLeaderBanditBow_disabled"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 250 @cr Holz: 80")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerRecruitBlackKnight()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BuyLeaderBlackKnight_disabled"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 250 @cr Eisen: 60")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerRecruitElite()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BuyLeaderElite_disabled"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 1000 @cr Eisen: 320 @cr Silber: 80")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerRecruitBearman()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BuyLeaderEvilBear_disabled"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 150 @cr Eisen: 30")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerRecruitSkirmisher()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BuyLeaderEvilSkir_disabled"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 150 @cr Holz: 60")
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomShortCut, " ")
end
function GUITooltip_MercenaryTowerBearmanCulture()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BearmanCulture_normal"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 600 @cr Eisen: 400")
end
function GUITooltip_MercenaryTowerBanditCulture()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BanditCulture_normal"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 600 @cr Eisen: 400")
end
function GUITooltip_MercenaryTowerBarbarianCulture()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/BarbarianCulture_normal"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 600 @cr Eisen: 400")
end
function GUITooltip_MercenaryTowerKnightsCulture()
	XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, XGUIEng.GetStringTableText("MenuMercenaryTower/KnightsCulture_normal"))
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts,"@color:255,255,255,255 Taler: 600 @cr Eisen: 400")
end
function GUITooltip_ResourceSilver()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Silber @cr @color:255,255,255,255 Diese Menge Silber steht Euch im Moment zur Verfügung.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_ResourceFaith()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Glaube @cr @color:255,255,255,255 Dieser Prozentsatz Glaube steht Euch im Moment zur Verfügung.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_ResourceWeatherEnergy()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Wetterenergie @cr @color:255,255,255,255 Dieser Prozentsatz Wetterenergie steht Euch im Moment zur Verfügung.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DetailedResourceView()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Erweiterte Ressourcen-Anzeige @cr @color:255,255,255,255 Klickt hier, um Euch Details zu Euren Ressourcen anzeigen zu lassen.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_NormalResourceView()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Normale Ressourcen-Anzeige @cr @color:255,255,255,255 Klickt hier, um zur normalen Ressourcen-Anzeige zurück zu kehren.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_RPGView()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 RPG-Sichtmodus @cr @color:255,255,255,255 Klickt hier, um zum RPG-Sichtmodus zu wechseln.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DownView()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Draufsicht-Modus @cr @color:255,255,255,255 Klickt hier, um zur Draufsicht zu wechseln.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_NormalView()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 normaler Sichtmodus @cr @color:255,255,255,255 Klickt hier, um zum normalen Sichtmodus zu wechseln.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_Time()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 aktuelle Uhrzeit @cr @color:255,255,255,255 Hier wird die aktuelle Uhrzeit des Spiels angezeigt. @cr Sonnenaufgang: 06:00 Uhr @cr Sonnenuntergang: 20:00 Uhr")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DetailsLeader()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Erweiterte Stats-Anzeige @cr @color:255,255,255,255 Klickt hier, um Euch Details zur Stärke Eurer Soldaten anzeigen zu lassen.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_DetailsLeaderOff()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Normale Stats-Anzeige @cr @color:255,255,255,255 Klickt hier, um zur normalen Anzeige zurück zu kehren.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_ExpelAll()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Massenentlassung @cr @color:255,255,255,255 Klickt hier, um alle selektierten Einheiten zu entlassen.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_AttackRange()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Angriffsreichweite @cr @color:255,255,255,255 Dies zeigt die aktuelle Angriffsreichweite dieser Einheit an.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_VisionRange()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Sichtreichweite @cr @color:255,255,255,255 Dies zeigt die aktuelle Sichtreichweite dieser Einheit an.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_AttackSpeed()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Angriffstempo @cr @color:255,255,255,255 Dies zeigt das aktuelle Angriffstempo dieser Einheit an (in Angriffe pro 1000s)")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end
function GUITooltip_MoveSpeed()
	local CostString = " "
	local ShortCutToolTip = " "	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, "@color:180,180,180 Lauftempo @cr @color:255,255,255,255 Dies zeigt das aktuelle Lauftempo dieser Einheit an.")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
end