class HE_HUDMedic extends HE_HUDBase
	DependsOn(HE_DataStructure)
	config(HealingExtend);

//*********************************************************
//* Misc
//*********************************************************
simulated function FinalSkill()
{
	super.FinalSkill();
}

//*********************************************************
//* Exec
//*********************************************************
exec function TriggerFinalSkill()
{
	super.TriggerFinalSkill();
}

exec function TriggerOptionalSkill()
{
	
}

//*********************************************************
//* Render Main
//*********************************************************
//Draw need healing icon when player's health is low
//Rewrite to fit medic healing patterns
simulated function bool DrawPlayerHealthLowIcon(KFPawn_Human KFPH, optional bool isDebug)
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

//Draw hidden player icons
//Rewrite to fit medic healing patterns, just like Overwatch's medic
//Can see teammate's health through the HUD
function DrawHiddenHumanPlayerIcon( PlayerReplicationInfo PRI, vector IconWorldLocation )
{
	local float Percentage;
	local float BarHeight, BarLength, BarSpace;
    local vector ScreenPos;
    local float IconSizeMult;
    local KFPlayerReplicationInfo KFPRI;
    local Texture2D PlayerIcon;
	local float LX, LY;
	local string NotifyText;
	
	NotifyText=" ";
	BarLength = FMin(PlayerStatusBarLengthMax * (float(Canvas.SizeX) / 1024.f), PlayerStatusBarLengthMax) * FriendlyHudScale;
	BarHeight = FMin(8.f * (float(Canvas.SizeX) / 1024.f), 8.f) * FriendlyHudScale;
	BarSpace = 2.f;

    KFPRI = KFPlayerReplicationInfo(PRI);
    if( KFPRI == none )
    {
    	return;
    }

    // Project world pos to canvas
    ScreenPos = Canvas.Project( IconWorldLocation + vect(0,0,2.2f) * class'KFPAwn_Human'.default.CylinderComponent.CollisionHeight );

    // Fudge by icon size
    IconSizeMult = PlayerStatusIconSize * FriendlyHudScale * 0.5f;
    ScreenPos.X -= IconSizeMult;
    ScreenPos.Y -= IconSizeMult;

    if( ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY )
    {
        return;
    }

    PlayerIcon = PlayerOwner.GetTeamNum() == 0 ? KFPRI.CurrentPerkClass.default.PerkIcon : GenericHumanIconTexture;

    // Draw human icon
    //Draw health state
	if( KFPRI.PlayerHealthPercent < 255 )
	{
		Canvas.SetDrawColor(220, 220, 220, 192);
		Canvas.StrLen("Notify", LX, LY);
		NotifyText="Notify";
	}
	if( KFPRI.PlayerHealthPercent <= 216)
	{
		Canvas.SetDrawColorStruct(LowSeverityColor);
		Canvas.StrLen("Hurt", LX, LY);
		NotifyText="Hurt";
	}
	if( KFPRI.PlayerHealthPercent <= 127)
	{
		Canvas.SetDrawColorStruct(CriticalSeverityColor);
		Canvas.StrLen("Dying", LX, LY);
		NotifyText="Dying";
	}
    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
    Canvas.DrawTile( PlayerIcon, PlayerStatusIconSize * FriendlyHudScale, PlayerStatusIconSize * FriendlyHudScale, 0, 0, 256, 256 );
	
	//Draw text
	Canvas.SetPos(ScreenPos.X - LX*0.5f + PlayerStatusIconSize*0.5f, ScreenPos.Y + PlayerStatusIconSize*0.5f + BarSpace);
	Canvas.DrawText(NotifyText);
	//Draw health bar
	if( KFPRI.PlayerHealthPercent < 255 )
	{
		Percentage = float(KFPRI.PlayerHealthPercent) / 255.f;
		DrawKFBar(Percentage, BarLength, BarHeight, ScreenPos.X - (BarLength * 0.5f) + PlayerStatusIconSize*0.5f, ScreenPos.Y + PlayerStatusIconSize*0.5f + 2*BarSpace + BarHeight, HealthColor);
	}
}

defaultproperties
{
	bDrawEnergyBar=True;
}