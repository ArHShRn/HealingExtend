class InstantHealing extends Mutator;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(5, true, 'LogStatus');
}

simulated function LogStatus()
{
	`Log("[ArHShRn.Mutators] InstantHealing Mut is working fine!");
}

function ModifyPlayer(Pawn Other)
{
	local KFPawn_Human KFPH;
	KFPH=KFPawn_Human(Other);
	KFPH.HealthRegenRate=0.01;
	super.ModifyPlayer(Other);	
}

defaultproperties
{
}