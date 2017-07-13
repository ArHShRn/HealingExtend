//=============================================================================
// Healing Extend Mutator : Instant Healing
// This is the first mutator containing in HealingExtend Mut
// 
// This mutator provides you the possibility to recover Health 
//		for a customized health regen rate
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//=============================================================================
class InstantHealing extends Mutator
	config(HealingExtend);

	var config float					fCurrentRegenRate;
	var config bool						bInitedConfig;

function InitMutator(string Options, out string ErrorMessage)
{
	if(!bInitedConfig)
	{
		InitBasicMutatorValues();
		SaveConfig();
	}
	super.InitMutator( Options, ErrorMessage );
}

function InitBasicMutatorValues()
{
	fCurrentRegenRate=40.0;
	bInitedConfig=True;
}

function PostBeginPlay()
{
	SaveConfig();
	SetTimer(5, true, 'LogStatus');
	super.PostBeginPlay();
}

simulated function LogStatus()
{
	`Log("[ArHShRn.Mutators] InstantHealing Mut is working fine!");
}

function ModifyPlayer(Pawn Other)
{
	local KFPawn_Human KFPH;
	KFPH=KFPawn_Human(Other);
	KFPH.HealthRegenRate=(1/fCurrentRegenRate);
	super.ModifyPlayer(Other);	
}

defaultproperties
{
}