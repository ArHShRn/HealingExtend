//=============================================================================
// Healing Extend Mutator : Healing Extend(HE) HUD Base Class
// This class is the base class of the HE mut's HUD
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.1
//
// -Auto-hide health bar when the player is full
//
// Last Update Date Oct.11th 2017
//=============================================================================
class HE_HUDBase extends KFGFxHudWrapper
	Config(HE_HUDBase);

//*********************************************************
//* Variables
//*********************************************************
//Mutator Version Info
var config HEVersionInfo HEVI;
var HEVersionInfo Editable_HEVI;

//System
var HE_HUDManager		ManagerOwner;

var float				LastX,LastY,StartX,StartY;

var bool				bASSAim;
var bool				bDrawCenterMsg;

var float				ScreenX, ScreenY;
var float				PresetX, PresetY;

var int					Default_HurtHealthRateNotify;
var int					Default_CriticalHealthRateNotify;

var string				CenterMessage;

var HUDCrosshairStatus	HECS;
var AsCMode				CSMode;

//Status
var bool				bIsPlayerDead;
var bool				bIsUpkUser;
var bool				bIsUsingOldASC;

//Debug
var bool				bDrawDebug;
var bool				bDrawDebugPI;

//Tests
var int					PicAnimFlag;

//Colors
var color				Default_MainHUDColor;
var color				Default_DebugHUDColor;
var color				Default_CrosshairColor;
var color				Default_OverclockedHealthColor;
var color				Default_OverclockedArmorColor;
var color				Default_LowSeverityColor;
var color				Default_CriticalSeverityColor;
var color				Default_EnergyBarColor;

//Textures
var Texture2D			Crosshair1;
var Texture2D			FleshpoundIcon;
var Texture2D			ScrakeIcon;
var Texture2D			GenericZedIconTextureNoUpk;

//*********************************************************
//* Configs
//*********************************************************
var config bool			bInitedConfig;
var config float		ASSAim_Length;
var config float		ASSAim_Space;
var config float		ASSAim_Width;
var config float		HUDMainTextScale;
var config float		HUDDebugTextScale;

var config int			HurtHealthRateNotify;
var config int			CriticalHealthRateNotify;			

var config color		MainHUDColor;
var config color		DebugHUDColor;

var config color		CrosshairColor;

var config color		OverclockedHealthColor;
var config color		OverclockedArmorColor;

var config color		LowSeverityColor;
var config color		CriticalSeverityColor;

//*********************************************************
//* Initialization
//*********************************************************
Event PreBeginPlay()
{
	//Force init in client or it will fail to work
	//Disadvantage: Player would not change the color themselves
	InitBasicValues();
	SaveConfig();
	super.PreBeginPlay();
}

simulated function PostBeginPlay()
{	
	super.PostBeginPlay();
}

function InitBasicValues()
{
	//Muatator Version Info
	Editable_HEVI.ThisMutatorName="HE_HUDBase";
	Editable_HEVI.AuthorNickname="ArHShRn";
	Editable_HEVI.AuthorSteamcommunityURL="http://steamcommunity.com/id/ArHShRn/";
	Editable_HEVI.Version="Release 1.1.1";
	Editable_HEVI.LastUpdate="Oct.11th 2017 08:55 PM";
	HEVI=Editable_HEVI;
	
	bInitedConfig=True;
	ASSAim_Width=3.0f;
	ASSAim_Length=12.0f;
	ASSAim_Space=8.0f;
	HUDMainTextScale=1.0f;
	HUDDebugTextScale=1.0f;
	
	HurtHealthRateNotify=Default_HurtHealthRateNotify;
	CriticalHealthRateNotify=Default_CriticalHealthRateNotify;
	
	bShowHUD=True; //Force player use HUD
	
	MainHUDColor=Default_MainHUDColor; //Yellow
	DebugHUDColor=Default_DebugHUDColor; //Pink
	CrosshairColor=Default_CrosshairColor; //Red
	OverclockedArmorColor=Default_OverclockedArmorColor; //Sea Green 2
	OverclockedHealthColor=Default_OverclockedHealthColor; //Original blue
	LowSeverityColor=Default_LowSeverityColor; //Yellow
	CriticalSeverityColor=Default_CriticalSeverityColor; //Red
	
	if( GenericZedIconTexture != None )
	{
		bIsUpkUser = True;
		`log("---[HE_HUDBase::InitBasicValues]This user is a upk-user, draw customized contents.");
	}
}

//Set this class's owner manager
simulated function SetHUDManager(HE_HUDManager AManager)
{
	ManagerOwner = AManager;
	`log("---[HE_HUDBase::SetHUDManager]ManagerOwner sets to "$ManagerOwner.Name);
}
//*********************************************************
//* Misc
//*********************************************************

//Print sth in console
simulated function Print( string message, optional bool autoPrefix = true )
{
	local GameViewportClient LocalGVC;

	if ( autoPrefix )
	{
		message = "[HE_HUD:"$WorldInfo.NetMode$"] "$message;
	}

	LocalGVC = class'GameEngine'.static.GetEngine().GameViewport;

	if ( LocalGVC != None )
	{
		LocalGVC.ViewportConsole.OutputTextLine(message);
	}
}

simulated function AddChatLine(string str)
{
	KFPlayerOwner.MyGFxHUD.HudChatBox.AddChatMessage(str, class 'KFLocalMessage'.default.EventColor);
}
//*********************************************************
//* Exec
//*********************************************************

//Console command to toggle draw debug info
exec function HEDrawDebug()
{
	bDrawDebug=!bDrawDebug;
	if(bDrawDebug)
		Print("Enable Debug Draw");
	else
		Print("Disable Debug Draw");
}

//Console command to toggole draw debug PI
exec function HEDrawDebugPI()
{
	bDrawDebugPI=!bDrawDebugPI;
	if(bDrawDebugPI)
		Print("Enable Debug PI Draw");
	else
		Print("Disable Debug PI Draw");
}

//Console command to toggle AsC
exec function ToggleAsC()
{
	bASSAim=!bASSAim;
	if(bASSAim)
	{
		AddChatLine("[HE_HUDBase]Enable Crosshair Draw");
		Print("[HE_HUDBase]Enable Crosshair Draw");
	}
	else
	{
		AddChatLine("[HE_HUDBase]Close Crosshair Draw");
		Print("[HE_HUDBase]Close Crosshair Draw");
	}	
}

//Console command CHN pinyin to toggle AsC
exec function ZhunXin()
{
	ToggleAsC();
}

//Console command CHN pinyin to change AsC draw mode
exec function HuanZhunXin()
{
	ChangeAsCMode();
}

//Console command to change AsC draw mode
exec function ChangeAsCMode()
{
	bIsUsingOldASC=!bIsUsingOldASC;
	if(bIsUsingOldASC && bIsUpkUser)
	{
		AddChatLine("[HE_HUDBase]Changed To Old Crosshair Draw");
		Print("[HE_HUDBase]Changed To Old Crosshair Draw");
	}
	else if(!bIsUsingOldASC && bIsUpkUser)
	{
		AddChatLine("[HE_HUDBase]Changed To New Crosshair Draw");
		Print("[HE_HUDBase]Changed To New Crosshair Draw");
	}
	else if(!bIsUpkUser)
	{
		Print("Crosshair pattern can't be changed!");
		Print("Please download HE_Contents.upk and put it in a right folder:");
		Print("\Documents\My Games\KillingFloor2\KFGame\Unpublished\BrewedPC\Packages\HealingExtend_Contents");
		Print("Or");
		Print("\Documents\My Games\KillingFloor2\KFGame\Published\BrewedPC\Packages\HealingExtend_Contents");
	}
}

exec function DebugGlobalMsg(string message)
{
	ManagerOwner.GlobalHUDMessage(message);
}

//*********************************************************
//* Tests
//*********************************************************

//Same as DrawFriendlyHumanPlayerInfo but its pos is at Center screen
//And its pawn is yourself
//Copy code here at any change of the original code!!!!!!!!!!!!
simulated function bool DrawDebugHumanPlayerInfo()
{
	local KFPawn_Human KFPH;
	local byte PerkLv;
	local float Percentage;
	local float BarHeight, BarLength, BarSpace;
	local string PerkLvText;
	local vector ScreenPos;
	local KFPlayerReplicationInfo KFPRI;
	local FontRenderInfo MyFontRenderInfo;
	local float FontScale;
	local color TempColor;
	
	KFPH = KFPawn_Human(KFPlayerOwner.Pawn);
	if(KFPH == None)
		return false;
	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}

	MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
	BarLength = FMin(PlayerStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), PlayerStatusBarLengthMax) * FriendlyHudScale;
	BarHeight = FMin(8.f * (float(Canvas.SizeX) / 1024.f), 8.f) * FriendlyHudScale;
	BarSpace = 4.f;

	ScreenPos.X = CenterX;
	ScreenPos.Y = CenterY;
	
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}

	//Draw health bar
		//Draw health up limit
	Canvas.SetPos(ScreenPos.X + (BarLength * 0.5f) + BarSpace, ScreenPos.Y);
	Canvas.DrawRect(2, BarHeight);
	//if player's health is under HealthMax
	if( KFPH.Health - KFPH.HealthMax <=0)
	{
		Percentage = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);	
	}
	else
	{
		//First draw the original health bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);
		//Then draw overclocked health bar	
		Percentage = FMin(float(KFPH.Health - KFPH.HealthMax) / 75.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, OverclockedHealthColor);
	}

	//Draw armor bar
	//if player's armor is under MaxArmor
	if( KFPH.Armor - KFPH.MaxArmor <=0)
	{
		Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);		
	}
	else
	{
		//First draw the original armor bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);	
		//Then draw overclocked armor bar
		Percentage = FMin(float(KFPH.Armor - KFPH.MaxArmor) / 100.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, OverclockedArmorColor);	
	}


	//Draw player name (Top)
	FontScale = class'KFGameEngine'.Static.GetKFFontScale();
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight * 3.8);
	Canvas.DrawText( KFPRI.PlayerName,,FontScale * FriendlyHudScale,FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.CurrentPerkClass == none )
	{
		return false;
	}

	//draw perk icon
	Canvas.SetDrawColorStruct(PlayerBarIconColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.75), ScreenPos.Y - BarHeight * 2.0);
	Canvas.DrawTile(KFPRI.CurrentPerkClass.default.PerkIcon, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );

	//Draw perk level and name text
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 0.6);
	PerkLv=KFPRI.GetActivePerkLevel();
	if(PerkLv <= 10)
		PerkLvText = "Rookie";
	else if(PerkLv <= 20)
		PerkLvText = "Experienced";
	else
		PerkLvText = "Mastered";
	Canvas.DrawText( PerkLvText @KFPRI.CurrentPerkClass.default.PerkName,,FontScale * FriendlyHudScale, FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.PerkSupplyLevel > 0 && KFPRI.CurrentPerkClass.static.GetInteractIcon() != none )
	{
		if( KFPRI.PerkSupplyLevel == 2 )
		{
			if( KFPRI.bPerkPrimarySupplyUsed && KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierActiveColor;
			}
			else if( KFPRI.bPerkPrimarySupplyUsed || KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierHalfUsableColor;
			}
			else
			{
				TempColor = SupplierUsableColor;
			}
		}
		else if( KFPRI.PerkSupplyLevel == 1 )
		{
			TempColor = KFPRI.bPerkPrimarySupplyUsed ? SupplierActiveColor : SupplierUsableColor;
		}

		Canvas.SetDrawColorStruct( TempColor );
		Canvas.SetPos( ScreenPos.X + BarLength * 0.5f + 2*BarSpace + 2, ScreenPos.Y - BarHeight * 2 );
		Canvas.DrawTile( KFPRI.CurrentPerkClass.static.GetInteractIcon(), PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256); 
	}

	return true;
}

//Same as DrawDebugFriendlyHumanPlayerInfo but its pos is editable
//And its pawn is yourself
//Copy code here at any change of the original code!!!!!!!!!!!!
simulated function bool DrawSelfHumanPlayerInfo()
{
	local KFPawn_Human KFPH;
	local byte PerkLv;
	local float Percentage;
	local float BarHeight, BarLength, BarSpace;
	local string PerkLvText;
	local vector ScreenPos;
	local KFPlayerReplicationInfo KFPRI;
	local FontRenderInfo MyFontRenderInfo;
	local float FontScale;
	local color TempColor;
	
	KFPH = KFPawn_Human(KFPlayerOwner.Pawn);
	if(KFPH == None)
		return false;
	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}

	MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
	BarLength = FMin(PlayerStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), PlayerStatusBarLengthMax) * FriendlyHudScale;
	BarHeight = FMin(8.f * (float(Canvas.SizeX) / 1024.f), 8.f) * FriendlyHudScale;
	BarSpace = 4.f;

	ScreenPos.X = CenterX;
	ScreenPos.Y = 0;
	
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}

		//Draw health bar
		//Draw health up limit
	Canvas.SetPos(ScreenPos.X + (BarLength * 0.5f) + BarSpace, ScreenPos.Y);
	Canvas.DrawRect(2, BarHeight);
	//if player's health is under HealthMax
	if( KFPH.Health - KFPH.HealthMax <=0)
	{
		Percentage = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);
		Canvas.SetPos(	ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y);
		Canvas.DrawText("-NORMAL-");
	}
	else
	{
		//First draw the original health bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);
		//Then draw overclocked health bar	
		Percentage = FMin(float(KFPH.Health - KFPH.HealthMax) / 75.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, OverclockedHealthColor);
		Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y);
		Canvas.DrawText("=OVERCLOCKING=");
	}

	//Draw armor bar
	//if player's armor is under MaxArmor
	if( KFPH.Armor - KFPH.MaxArmor <=0)
	{
		Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);	
		Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight);
		Canvas.DrawText("-NORMAL-");
	}
	else
	{
		//First draw the original armor bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);	
		//Then draw overclocked armor bar
		Percentage = FMin(float(KFPH.Armor - KFPH.MaxArmor) / 100.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, OverclockedArmorColor);
		Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight);
		Canvas.DrawText("=OVERCLOCKING=");	
	}


	//Draw player name (Top)
	FontScale = class'KFGameEngine'.Static.GetKFFontScale();
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight * 3.8);
	Canvas.DrawText( KFPRI.PlayerName,,FontScale * FriendlyHudScale,FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.CurrentPerkClass == none )
	{
		return false;
	}

	//draw perk icon
	Canvas.SetDrawColorStruct(PlayerBarIconColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.75), ScreenPos.Y - BarHeight * 2.0);
	Canvas.DrawTile(KFPRI.CurrentPerkClass.default.PerkIcon, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );

	//Draw perk level and name text
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 0.6);
	PerkLv=KFPRI.GetActivePerkLevel();
	if(PerkLv <= 10)
		PerkLvText = "Rookie";
	else if(PerkLv <= 20)
		PerkLvText = "Experienced";
	else
		PerkLvText = "Mastered";
	Canvas.DrawText( PerkLvText @KFPRI.CurrentPerkClass.default.PerkName,,FontScale * FriendlyHudScale, FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.PerkSupplyLevel > 0 && KFPRI.CurrentPerkClass.static.GetInteractIcon() != none )
	{
		if( KFPRI.PerkSupplyLevel == 2 )
		{
			if( KFPRI.bPerkPrimarySupplyUsed && KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierActiveColor;
			}
			else if( KFPRI.bPerkPrimarySupplyUsed || KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierHalfUsableColor;
			}
			else
			{
				TempColor = SupplierUsableColor;
			}
		}
		else if( KFPRI.PerkSupplyLevel == 1 )
		{
			TempColor = KFPRI.bPerkPrimarySupplyUsed ? SupplierActiveColor : SupplierUsableColor;
		}

		Canvas.SetDrawColorStruct( TempColor );
		Canvas.SetPos( ScreenPos.X + BarLength * 0.5f + 2*BarSpace + 2, ScreenPos.Y - BarHeight * 2 );
		Canvas.DrawTile( KFPRI.CurrentPerkClass.static.GetInteractIcon(), PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256); 
	}

	return true;
}

//*********************************************************
//* Render Main
//*********************************************************

//Check AsC Status
function CheckDrawASCStatus()
{
	local KFPawn KFP;
	local KFWeapon KFWP;
	local bool bMonsterPawn, bDrawCrosshairNoWeapon;
	local KFPerk MyKFPerk;
		
	// Only draw the crosshair if we're not in a vehicle and we have a living pawn
    if ( PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health > 0  )
	{
		bIsPlayerDead=False;
		KFWP = KFWeapon(PlayerOwner.Pawn.Weapon);
		MyKFPerk = KFPlayerController(PlayerOwner).GetPerk();

		bMonsterPawn = PlayerOwner.GetTeamNum() == 255;

		// If our pawn class uses a crosshair regardless of weapon, draw it
		KFP = KFPawn( PlayerOwner.Pawn );
		bDrawCrosshairNoWeapon = KFP.bNeedsCrosshair;

        // Don't draw the crosshair if we're not a monster with a weapon class, or we're not forcing the crosshair for the zed without a weapon
        if( bMonsterPawn )
        {
        	HECS=HE_Player_Monster;
            if( !bDrawCrosshairNoWeapon )
            {
				HECS=HE_Player_NoWeap;
                return;
            }
        }

		// Don't draw the crosshair if we don't have a weapon, or are using ironsights
		if( !bDrawCrosshairNoWeapon )
		{
	        if( (!bMonsterPawn && MyKFPerk == none) || KFWP == none || !bForceDrawCrosshair && (KFWP.bUsingSights /*|| KFWP.bResting*/) )
			{
				HECS=HE_Player_UsingIronsight;
	            return;
			}

			// Skip if weapon is missing spread settings
			if ( KFWP.Spread.Length == 0 && !bForceDrawCrosshair )
			{
				HECS=HE_WeapNotGuns;
				return;
			}
		}
		else
			HECS=HE_Player_NoWeap;

		// Don't draw the crosshair if our special move won't allow it
		if( KFP.IsDoingSpecialMove() && !KFP.SpecialMoves[KFP.SpecialMove].CanDrawCrosshair() )
		{
			HECS=HE_Player_SpecialMoveDontAllow;
			return;
		}
		DrawAsCAim(bASSAim, KFWP, CSMode);
	}
	else if(PlayerOwner.Pawn != none && PlayerOwner.Pawn.Health <= 0)
	{
		bIsPlayerDead=True;
		HECS=HE_Player_Dead;
	}
}

/*Rewrite sth in super.super class, just copy the
  super class's code */
//DrawHUD main function
function DrawHUD()
{
	//local vector ViewPoint;
	//local rotator ViewRotation;
	local float XL, YL, YPos;
	local vector ViewPoint;
	local rotator ViewRotation;
	local KFPawn_Human KFPH;
	local vector ViewLocation, ViewVector, PlayerPartyInfoLocation;
    local array<PlayerReplicationInfo> VisibleHumanPlayers;
    local array<sHiddenHumanPawnInfo> HiddenHumanPlayers;
    
    ScreenX=CenterX*2;
	ScreenY=CenterY*2;
	StartX=ScreenX*PresetX;
	StartY=ScreenY*PresetY;

    // Draw weapon HUD underneath everything else
    if( KFPlayerOwner != none && KFPlayerOwner.Pawn != none && KFPlayerOwner.Pawn.Weapon != none )
    {
    	KFPlayerOwner.Pawn.Weapon.DrawHUD( self, Canvas );
    }
	
	//-------------------------------------------HUD Class
	if ( bShowOverlays && (PlayerOwner != None) )
	{
		Canvas.Font = GetFontSizeIndex(0);
		PlayerOwner.GetPlayerViewPoint(ViewPoint, ViewRotation);
		DrawActorOverlays(Viewpoint, ViewRotation);
	}
	PlayerOwner.DrawHud( Self );

	//-------------------------------------------KFHUDBase class
	// Cache GRI
    if( KFGRI == none )
    {
        KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
    }

    // Don't draw canvas HUD in cinematic mode
	if( KFPlayerOwner != none && KFPlayerOwner.bCinematicMode )
	{
		return;
	}

	// Draw the crosshair for casual mode
	if( KFPlayerOwner != none && (bDrawCrosshair || bForceDrawCrosshair || KFPlayerOwner.GetTeamNum() == 255) )
	{
        DrawCrosshair();
    }

	//----------------------------------Main HE_HUD Customized Draw Flow Put Here!-----------------------------
	if(bDrawDebugPI)
	{
		DrawDebugHumanPlayerInfo();
		DrawPlayerHealthLowIcon(KFPawn_Human(KFPlayerOwner.Pawn), True);
	}
	
	if(bDrawCenterMsg)
		FuncDrawCenterMsg();
	
	//Check and Draw Assistant Crosshair
	CheckDrawASCStatus();
	//---------------------------------------------------------------------------------------------------------
    // Friendly player status
    if( PlayerOwner.GetTeamNum() == 0 )
    {
		if( KFPlayerOwner != none )
		{
		    KFPlayerOwner.GetPlayerViewPoint( ViewLocation, ViewRotation );
		}
		ViewVector = vector(ViewRotation);

	    Canvas.EnableStencilTest(true);
		foreach WorldInfo.AllPawns( class'KFPawn_Human', KFPH )
		{
			if( KFPH.IsAliveAndWell() && KFPH != KFPlayerOwner.Pawn && KFPH.Mesh.SkeletalMesh != none && KFPH.Mesh.bAnimTreeInitialised )
			{
				PlayerPartyInfoLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,1) );
				if(`TimeSince(KFPH.Mesh.LastRenderTime) < 0.2f && Normal(PlayerPartyInfoLocation - ViewLocation) dot ViewVector > 0.f )
				{
					//-------------------------------------------------------Customized HUD Draw Flow-----------------------
					if(KFPlayerOwner.GetPerk().GetPerkClass() == class'KFPerk_FieldMedic')
						Medic_DrawPlayerHealthLowIcon(KFPH, False);
					else
						DrawPlayerHealthLowIcon(KFPH, False);
					//-------------------------------------------------------Customized HUD Draw Flow-----------------------	
					if( DrawFriendlyHumanPlayerInfo(KFPH) )
					{
						VisibleHumanPlayers.AddItem( KFPH.PlayerReplicationInfo );
					}
					else
					{
						HiddenHumanPlayers.Insert( 0, 1 );
                    	HiddenHumanPlayers[0].HumanPawn = KFPH;
                    	HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
					}
				}
				else 
                {
                    HiddenHumanPlayers.Insert( 0, 1 );
                    HiddenHumanPlayers[0].HumanPawn = KFPH;
                    HiddenHumanPlayers[0].HumanPRI = KFPH.PlayerReplicationInfo;
                }
			}
		}

		if( !KFGRI.bHidePawnIcons )
		{
			// Draw hidden players
			CheckAndDrawHiddenPlayerIcons( VisibleHumanPlayers, HiddenHumanPlayers );

			// Draw last remaining zeds
			CheckAndDrawRemainingZedIcons();

			//Draw our current objective's location
			if(KFGRI.CurrentObjective != none)
			{
				DrawObjectiveHUD();
			}
		}

		Canvas.EnableStencilTest(false);
	}
	//---------------------------------------------------------KFGFxHudWrapper Class
	// Don't draw canvas HUD in cinematic mode
    if( KFPlayerOwner != none && KFPlayerOwner.bCinematicMode )
    {
        return;
    }

	if ( bCrosshairOnFriendly )
	{
		// verify that crosshair trace might hit friendly
		bGreenCrosshair = CheckCrosshairOnFriendly();
		bCrosshairOnFriendly = false;
	}
	else
	{
		bGreenCrosshair = false;
	}

	if ( bShowDebugInfo )
	{
		Canvas.Font = GetFontSizeIndex(0);
		Canvas.DrawColor = ConsoleColor;
		Canvas.StrLen("X", XL, YL);
		YPos = 0;
		PlayerOwner.ViewTarget.DisplayDebug(self, YL, YPos);

		if (ShouldDisplayDebug('AI') && (Pawn(PlayerOwner.ViewTarget) != None))
		{
			DrawRoute(Pawn(PlayerOwner.ViewTarget));
		}
		return;
	}
}

//Draw need healing icon when player's health is low
simulated function bool DrawPlayerHealthLowIcon(KFPawn_Human KFPH, optional bool isDebug)
{
	local float LX, LY;
	local string NotifyText;
	local vector ScreenPos, TargetLocation;
	local KFPlayerReplicationInfo KFPRI;
	
	NotifyText="Pending...";

	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}
	
	if(isDebug)
	{
		ScreenPos.X = CenterX;
		ScreenPos.Y = CenterY;
	}
	else
	{
		TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,1.1f) );
		ScreenPos = Canvas.Project( TargetLocation );
	}
	
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}
	
	//Init draw pattern
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	//Only draw when teammates' health is below critical notify threshold
	if( KFPH.Health <= CriticalHealthRateNotify)
	{
		Canvas.SetDrawColorStruct(CriticalSeverityColor);
		Canvas.StrLen("Dying", LX, LY);
		NotifyText="Dying";
		//Draw need healing icon and text
		Canvas.SetPos(ScreenPos.X - 16.f, ScreenPos.Y - 16.f);
		Canvas.DrawTile(class'KFPerk_FieldMedic'.default.PerkIcon, 32.f * FriendlyHudScale, 32.f * FriendlyHudScale, 0, 0, 256, 256 );
		Canvas.SetPos(ScreenPos.X - LX*0.5f, ScreenPos.Y + 2.f + 16.f);
		Canvas.DrawText(NotifyText);
		return true;
	}
	return False;
}

//Medic Only
//Draw need healing icon when player's health is low
//Rewrite to fit medic healing patterns
simulated function bool Medic_DrawPlayerHealthLowIcon(KFPawn_Human KFPH, optional bool isDebug)
{
	local float LX, LY;
	local string NotifyText;
	local vector ScreenPos, TargetLocation;
	local KFPlayerReplicationInfo KFPRI;
	
	//If teammates dont need healing, return
	if(KFPH.Health >= KFPH.HealthMax)
		return false;
		
	NotifyText=" ";

	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}
	
	if(isDebug)
	{
		ScreenPos.X = CenterX;
		ScreenPos.Y = CenterY;
	}
	else
	{
		TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,1.1f) );
		ScreenPos = Canvas.Project( TargetLocation );
	}
	
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}
	
	//Init draw pattern
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	if( KFPH.Health <= KFPH.HealthMax)
	{
		Canvas.SetDrawColor(220, 220, 220, 192);
		Canvas.StrLen("Notify", LX, LY);
		NotifyText="Notify";
	}
	if( KFPH.Health <= HurtHealthRateNotify)
	{
		Canvas.SetDrawColorStruct(LowSeverityColor);
		Canvas.StrLen("Hurt", LX, LY);
		NotifyText="Hurt";
	}
	if( KFPH.Health <= CriticalHealthRateNotify)
	{
		Canvas.SetDrawColorStruct(CriticalSeverityColor);
		Canvas.StrLen("Dying", LX, LY);
		NotifyText="Dying";
	}
	
	//Draw need healing icon and text
	Canvas.SetPos(ScreenPos.X - 10.f, ScreenPos.Y - 10.f);
	Canvas.DrawTile(class'KFPerk_FieldMedic'.default.PerkIcon, 20.f * FriendlyHudScale, 20.f * FriendlyHudScale, 0, 0, 256, 256 );
	Canvas.SetPos(ScreenPos.X - LX*0.5f, ScreenPos.Y + 2.f + 10.f);
	Canvas.DrawText(NotifyText);
	
	return True;
}

//HE_HUD's bar drawing
//Re-work sth at DrawKFBar, draw a transparent but sketched tile
simulated function DrawKFBar( float BarPercentage, float BarLength, float BarHeight, float XPos, float YPos, Color BarColor )
{
	//background for status bar
	Canvas.SetDrawColorStruct(PlayerBarBGColor);
	
	Canvas.SetPos(XPos, YPos);
	//Left vertical
	Canvas.DrawRect(1, BarHeight);
	//Up horizonal
	Canvas.DrawRect(BarLength, 1);
	
	Canvas.SetPos(XPos, YPos+BarHeight);
	//Down horizonal
	Canvas.DrawRect(1, BarHeight);
	
	Canvas.SetPos(XPos+BarLength, YPos);
	//Right vertical
	Canvas.DrawRect(1, BarHeight);

	//Forground for status bar, which means a baaaaaar that indicate the health percent
	Canvas.SetDrawColorStruct(BarColor);
	Canvas.SetPos(XPos, YPos + 1);  // Adjust pos for border
	Canvas.DrawTile(PlayerStatusBarBGTexture, (BarLength - 2.0) * BarPercentage, BarHeight - 2.0, 0, 0, 32, 32);
}

//DrawFriendlyHumanPlayerInfo
//Version 1.1.2 Auto-Hide player info when the player's full
//Re-work sth at DrawFriendlyHumanPlayerInfo
//Example pool:
//
//           |--
//		PKIC |==============-----
//		PKIC |=====-----------
//           |-
//
simulated function bool DrawFriendlyHumanPlayerInfo(KFPawn_Human KFPH)
{
	local byte PerkLv;
	local float Percentage;
	local float BarHeight, BarLength, BarSpace;
	local string PerkLvText;
	local vector ScreenPos, TargetLocation;
	local KFPlayerReplicationInfo KFPRI;
	local FontRenderInfo MyFontRenderInfo;
	local float FontScale;
	local color TempColor;

	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	KFPRI = KFPlayerReplicationInfo(KFPH.PlayerReplicationInfo);

	if( KFPRI == none )
	{
		return false;
	}

	MyFontRenderInfo = Canvas.CreateFontRenderInfo( true );
	BarLength = FMin(PlayerStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), PlayerStatusBarLengthMax) * FriendlyHudScale;
	BarHeight = FMin(8.f * (float(Canvas.SizeX) / 1024.f), 8.f) * FriendlyHudScale;
	BarSpace = 2.f;

	TargetLocation = KFPH.Mesh.GetPosition() + ( KFPH.CylinderComponent.CollisionHeight * vect(0,0,2.2f) );

	ScreenPos = Canvas.Project( TargetLocation );
	if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
	{
		return false;
	}

	//Draw health bar
		//Draw health up limit
	Canvas.SetPos(ScreenPos.X + (BarLength * 0.5f) + BarSpace, ScreenPos.Y);
	Canvas.DrawRect(2, BarHeight);
	//if player's health is under HealthMax
	if( KFPH.Health - KFPH.HealthMax <=0)
	{
		Percentage = FMin(float(KFPH.Health) / float(KFPH.HealthMax), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);
		Canvas.SetPos(	ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y);
		Canvas.DrawText("-NORMAL-");
	}
	else
	{
		//First draw the original health bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, HealthColor);
		//Then draw overclocked health bar	
		Percentage = FMin(float(KFPH.Health - KFPH.HealthMax) / 75.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y, OverclockedHealthColor);
		Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y);
		Canvas.DrawText("=OVERCLOCKING=");
	}

	//Draw armor bar
	//if player's armor is under MaxArmor
	if( KFPH.Armor - KFPH.MaxArmor <=0)
	{
		Percentage = FMin(float(KFPH.Armor) / float(KFPH.MaxArmor), 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);	
		Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight);
		Canvas.DrawText("-NORMAL-");
	}
	else
	{
		//First draw the original armor bar
		DrawKFBar(1.0f, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, ArmorColor);	
		//Then draw overclocked armor bar
		Percentage = FMin(float(KFPH.Armor - KFPH.MaxArmor) / 100.f, 1.f);
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight, OverclockedArmorColor);
		Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight);
		Canvas.DrawText("=OVERCLOCKING=");	
	}


	//Draw player name (Top)
	FontScale = class'KFGameEngine'.Static.GetKFFontScale();
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y - BarHeight * 3.8);
	Canvas.DrawText( KFPRI.PlayerName,,FontScale * FriendlyHudScale,FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.CurrentPerkClass == none )
	{
		return false;
	}

	//draw perk icon
	Canvas.SetDrawColorStruct(PlayerBarIconColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.75), ScreenPos.Y - BarHeight * 2.0);
	Canvas.DrawTile(KFPRI.CurrentPerkClass.default.PerkIcon, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );

	//Draw perk level and name text
	Canvas.SetDrawColorStruct(PlayerBarTextColor);
	Canvas.SetPos(ScreenPos.X - (BarLength * 0.5f), ScreenPos.Y + BarHeight * 0.6);
	PerkLv=KFPRI.GetActivePerkLevel();
	if(PerkLv <= 10)
		PerkLvText = "Rookie";
	else if(PerkLv <= 20)
		PerkLvText = "Experienced";
	else
		PerkLvText = "Mastered";
	Canvas.DrawText( PerkLvText @KFPRI.CurrentPerkClass.default.PerkName,,FontScale * FriendlyHudScale, FontScale * FriendlyHudScale, MyFontRenderInfo );

	if( KFPRI.PerkSupplyLevel > 0 && KFPRI.CurrentPerkClass.static.GetInteractIcon() != none )
	{
		if( KFPRI.PerkSupplyLevel == 2 )
		{
			if( KFPRI.bPerkPrimarySupplyUsed && KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierActiveColor;
			}
			else if( KFPRI.bPerkPrimarySupplyUsed || KFPRI.bPerkSecondarySupplyUsed )
			{
				TempColor = SupplierHalfUsableColor;
			}
			else
			{
				TempColor = SupplierUsableColor;
			}
		}
		else if( KFPRI.PerkSupplyLevel == 1 )
		{
			TempColor = KFPRI.bPerkPrimarySupplyUsed ? SupplierActiveColor : SupplierUsableColor;
		}

		Canvas.SetDrawColorStruct( TempColor );
		Canvas.SetPos( ScreenPos.X + BarLength * 0.5f + 2*BarSpace + 2, ScreenPos.Y - BarHeight * 2 );
		Canvas.DrawTile( KFPRI.CurrentPerkClass.static.GetInteractIcon(), PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256); 
	}

	return true;
}

//A function that draw an assistant crosshair despite of the original
//Release 1.0.2: Remove some modes.
//Draw a crosshair through a pic from .upk
function DrawAsCAim(bool Enable, KFWeapon KFW, optional AsCMode mode=AsC_Default)
{
	if(!Enable)
	{
		HECS=HE_Player_Closed;
		return;
	}
	HECS=HE_Good;
	
	Canvas.SetDrawColorStruct(CrosshairColor);
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	
	//AsC Drawing
	if(bIsUpkUser && !bIsUsingOldASC) //Draw UPK contents, has no reload notification
	{
		Canvas.SetPos(CenterX-40, CenterY-40);
		Canvas.DrawTile(Crosshair1, 80, 80, 0, 0, 256, 256);
	}
	else //Draw Original AsC, has reload notification
	{
		//Crosshair with center dot
		//Up
		Canvas.SetPos(CenterX-ASSAim_Width*0.5f, CenterY-ASSAim_Space-ASSAim_Length);
		Canvas.DrawRect(ASSAim_Width,ASSAim_Length);
		//Left
		Canvas.SetPos(CenterX-ASSAim_Space-ASSAim_Length, CenterY-ASSAim_Width*0.5f);
		Canvas.DrawRect(ASSAim_Length,ASSAim_Width);	
		//Down
		Canvas.SetPos(CenterX-ASSAim_Width*0.5f, CenterY+ASSAim_Space);
		Canvas.DrawRect(ASSAim_Width,ASSAim_Length);
		//Right
		Canvas.SetPos(CenterX+ASSAim_Space, CenterY-ASSAim_Width*0.5f);
		Canvas.DrawRect(ASSAim_Length,ASSAim_Width);
		//Dot
		Canvas.SetPos(CenterX-2, CenterY-2);
		Canvas.DrawRect(4, 4);
		
		//Reload notification
		
	}
}

//Draws a zed icon
//re-work super class, adds FP SC Zedd's individual new UI Icon
function DrawZedIcon( Pawn ZedPawn, vector PawnLocation, float NormalizedAngle)
{
    local vector ScreenPos, TargetLocation;
    local float IconSizeMult;

    TargetLocation = PawnLocation + ( vect(0,0,2.2f) * ZedPawn.CylinderComponent.CollisionHeight );
    ScreenPos = Canvas.Project( TargetLocation );
    IconSizeMult = PlayerStatusIconSize * FriendlyHudScale * 0.5f;
    ScreenPos.X -= IconSizeMult;
    ScreenPos.Y -= IconSizeMult;

    if (NormalizedAngle > 0)
	{
		ScreenPos.x = FClamp(ScreenPos.x, PlayerStatusIconSize * FriendlyHudScale, Canvas.SizeX - (PlayerStatusIconSize * FriendlyHudScale));
	}
	else
	{
		ScreenPos = GetClampedScreenPosition(ScreenPos);
	}

     //Draw icon
    Canvas.SetDrawColorStruct( ZedIconColor );
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
	//If zed's a FP
	if(KFPawn_ZedFleshpound(ZedPawn) != None && bIsUpkUser)
		Canvas.DrawTile( FleshpoundIcon, 50, 50, 0, 0, 256, 256 );
	//Or if zed's a SC
	else if(KFPawn_ZedScrake(ZedPawn) != None && bIsUpkUser)
		Canvas.DrawTile( ScrakeIcon, 50, 50, 0, 0, 256, 256 );
	//Or they're normal
	else if(bIsUpkUser)
		Canvas.DrawTile( GenericZedIconTexture, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );
	else
		Canvas.DrawTile( GenericZedIconTextureNoUpk, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );
}

////Draw animated png
//function DrawAnimated()
//{
	//if(PicAnimFlag==3584)
		//PicAnimFlag=0;
//
	//Canvas.SetPos(CenterX, CenterY);
	//Canvas.DrawTile(TestIcon, 64, 64, 0, PicAnimFlag, 64, 64);
	//
	//PicAnimFlag += 64;
//}

//*********************************************************
//* Skill Base
//*********************************************************
//API:Draw Center Msg, using flag
//ATTENTION:Use this to draw msg
simulated function DrawCenterMsg(string Msg, optional int MsgLifTime=5)
{
	bDrawCenterMsg=True;
	
	CenterMessage=Msg;
	
	SetTimer(MsgLifTime, False, 'ClearDrawCenterMsgFlag');
}

//Draw Center Msg
simulated function FuncDrawCenterMsg()
{
	local float LX, LY;
	Canvas.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	Canvas.SetDrawColorStruct(MainHUDColor);
	Canvas.StrLen(CenterMessage, LX, LY);
	Canvas.SetPos(CenterX - LX*0.5f, CenterY*0.45f - LY);
	Canvas.DrawText(CenterMessage);
}

//Clear Center Msg notification
simulated function ClearDrawCenterMsgFlag()
{
	bDrawCenterMsg=False;
}

//Default Properties
defaultproperties
{	
	bDrawCenterMsg=False
	
	PicAnimFlag=0;
	
	CenterMessage="NULL"
	
	bIsUpkUser=False
	bDrawDebug=False
	bIsUsingOldASC=False
	bDrawDebugPI=False
	bASSAim=False
	CSMode=AsC_Default;
	bIsPlayerDead=False
	HECS=HE_NoneInit
	
	Default_HurtHealthRateNotify=85;
	Default_CriticalHealthRateNotify=50; //Need asking people
	
	Default_MainHUDColor=(R=255, G=255, B=0, A=192) //Yellow
	Default_DebugHUDColor=(R=255, G=192, B=203, A=192) //Pink
	Default_CrosshairColor=(R=255, G=48, B=48, A=192) //Red
	Default_OverclockedArmorColor=(R=238, G=233, B=233, A=192)//Snow
	Default_OverclockedHealthColor=(R=255, G=20, B=147, A=192)//Deep Pink
	Default_LowSeverityColor=(R=255, G=255, B=0, A=192) //Yellow
	Default_CriticalSeverityColor=(R=255, G=48, B=48, A=192) //Red
	
	PresetX=0.039f
	PresetY=0.28f
	
	ArmorColor=(R=238, G=233, B=233, A=192) //(R=238, G=233, B=233, A=192)Snow (R=0, G=0, B=233, A=192)Blue
	HealthColor=(R=255, G=20, B=147, A=192) //(R=255, G=20, B=147, A=192)DeepPink (R=233, G=0, B=0, A=192)Red
	PlayerBarBGColor=(R=160, G=32, B=240, A=0) //Set to purple, but completely transparant now
	PlayerBarTextColor=(R=248, G=248, B=255, A=192)//Navy Blue
	PlayerBarIconColor=(R=248, G=248, B=255, A=192)//Ghost White

	SupplierActiveColor=(R=128, G=128, B=128, A=192)
	SupplierUsableColor=(R=255, G=0, B=0, A=192)
	SupplierHalfUsableColor=(R=220, G=200, B=0, A=192)

    ZedIconColor=(R=0, G=191, B=255, A=192)  //(R=0, G=191, B=255, A=192)DeepSkyBlue (R=255, G=48, B=48, A=192)Red
    
    Crosshair1=Texture2D'HE_Contents.Crosshair_ss'
	ScrakeIcon=Texture2D'HE_Contents.ZeddAlert'
	FleshpoundIcon=Texture2D'HE_Contents.fleshpound'
    GenericZedIconTexture=Texture2D'HE_Contents.ZeddAlert'
	GenericZedIconTextureNoUpk=Texture2D'UI_PerkIcons_TEX.UI_PerkIcon_ZED'
}