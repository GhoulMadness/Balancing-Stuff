gvVStatue4 = gvVStatue4 or {}

gvVStatue4.MaxRange = 1500
gvVStatue4.DamageFactor = 0.90
-- Blockreichweite in Siedler-cm, abhängig von der Fläche der Map
gvVStatue4.BlockRange = 700 + math.floor(((Logic.WorldGetSize()/80)^2)/400)
-- max. Anzahl erlaubter Statuen
gvVStatue4.Limit = 5
gvVStatue4.PositionTable = {}
gvVStatue4.Amount = {}
for i = 1,12 do
	gvVStatue4.Amount[i] = 0
end