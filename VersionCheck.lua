BS.VersionCheck = {};
function BS.VersionCheck.Setup()
	BS.VersionCheck.Players = {};
	BS.VersionCheck.MyBSVersion = BS.Version;
	
	BS.VersionCheck.GetNetworkAdress = function()
		if CNetwork then
			return XNetwork.UserInSession_GetUserNameByNetworkAddress(XNetwork.Manager_GetLocalMachineNetworkAddress());
		else
			return UserTool_GetPlayerName(1);
		end
	end
	
	BS.VersionCheck.SetVersionForPlayer = function(_playerName, _BSVersion)
		BS.VersionCheck.Players[_playerName] =
		{
			BSVersion = _BSVersion,
		};
		BS.VersionCheck.CheckVersion();
	end
	
	BS.VersionCheck.VersionOutdated = function(_playerName, _version)
		return  " @color:255,255,255 " .. _playerName .. " - @color:255,72,53 " .. tostring(_version) .. " @cr ";
	end
	
	BS.VersionCheck.CheckVersion = function()
		local versionDifference = false;
		local breakMe = false;
		for PlayerIndex, VersionInfo in pairs(BS.VersionCheck.Players) do
			breakMe = false;
			for PlayerIndex2, VersionInfo2 in pairs(BS.VersionCheck.Players) do
				if VersionInfo.BSVersion ~= VersionInfo2.BSVersion then
					versionDifference = true;
					breakMe = true;
					break;
				end
			end
			if breakMe then break; end
		end
		
		if not versionDifference then
			return;
		end

		local versions = "";
		for PlayerIndex, VersionInfo in pairs(BS.VersionCheck.Players) do
			versions = versions .. BS.VersionCheck.VersionOutdated(PlayerIndex, VersionInfo.BSVersion);
		end
		XGUIEng.SetText("BS_VersionCheck_Title", " @color:255,72,53 Unterschiedliche BS - Versionen!");
		XGUIEng.SetText("BS_VersionCheck_Text", versions);
		XGUIEng.ShowWidget("BS_VersionCheck",1);
		XGUIEng.ShowWidget("SettlerServerInformation", 0)
		XGUIEng.ShowWidget("SettlerServerInformationExtended", 0);
		if EMS then
			XGUIEng.ShowWidget("EMSRORules",0);
			XGUIEng.ShowWidget("EMSMenu", 0)
		end
		
	end
	
	local delay = 5;
	BS_VersionCheck_Delay = function()
		if delay > 0 then
			delay = delay - 1;
			return;
		end
		Sync.CallNoSync("BS.VersionCheck.RequestVersions");
		return true;
	end
	StartSimpleJob("BS_VersionCheck_Delay");
	
	BS.VersionCheck.RequestVersions = function()
		local playerIndex = BS.VersionCheck.GetNetworkAdress();
		local BSVersion = BS.VersionCheck.MyBSVersion;
		
		if GUI.GetPlayerID() == 17 then
			-- spectators will only set their own version for them else - no one else cares about their version
			BS.VersionCheck.SetVersionForPlayer(playerIndex, BSVersion);
			return;
		end
		-- players will share their version with the others
		Sync.CallNoSync("BS.VersionCheck.SetVersionForPlayer", playerIndex, BSVersion);
	end
	
end