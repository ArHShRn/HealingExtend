class HE_RepTest extends Actor;

var string					strTest;
var int						intTest;

Replication
{
	if(Role <= ROLE_Authority)
		strTest, intTest;
}

simulated function PostBeginPlay()
{
	intTest=0; strTest="Now:"$intTest;
	super.PostBeginPlay();
	SetTimer(1.f, True, 'ChangeValue');
}

reliable client function ClientPrint(int SevrerInt, string SevrerStr)
{
	local GameViewportClient LocalGVC;
	LocalGVC = class'Engine'.static.GetEngine().GameViewport;
	if(LocalGVC == None)
		return;
		
	LocalGVC.ViewportConsole.OutputTextLine("Client.strTest="$strTest);
	LocalGVC.ViewportConsole.OutputTextLine("Client.intTest="$intTest);
	LocalGVC.ViewportConsole.OutputTextLine("Server.strTest="$SevrerStr);
	LocalGVC.ViewportConsole.OutputTextLine("Server.intTest="$SevrerInt);
}

function ChangeValue()
{
	intTest++; strTest="Now:"$intTest;
	ClientPrint(intTest, strTest);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}