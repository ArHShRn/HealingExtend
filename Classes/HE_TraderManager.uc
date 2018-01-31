//=============================================================================
// Healing Extend Mutator : Trader Manager
//	This class is created for managing customized weapons
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.1
// Explanation:
//	To get a customized weapon into Trader, we have to do following things:
//		1.Create a right Weapon class and a right Weapon Definition class
//		2.If it's in SOLO game, we need to add the item into GRI's TraderItems.SaleItems
//			and re-set a right info to let KFGRI and Trader know that we changed the
//			SaleItems (SetItemsInfo Function)
//		3.If it's an Online game, we should set it in Server Side and replicate it
//			down to the client side to control it.
// Tips In Achieving This:
//	In Online game section, first we spawn a manager to manage it, makes it a
//		"RemoteRole = ROLE_SimulatedProxy" actor, then we set SaleItems in server,
//		then, we the SalesItems will be replicated to client side (Original Inventory)
//		and this proccedure takes time, so we have to set a timer to check it in cycle
//		to find if it's replicated, once it is, we will set our new Trader Item into
//		client side's SaleItems, makes them synchronized and set info.
//		Then, it's time to have fun
//
// Last Update Date Oct.11th 2017
//=============================================================================
class HE_TraderManager extends Actor
	Config(HE_Main);

struct CustomizedWeap
{
	var string DefClassPath; //WeapDef Path !!!!
	var string WeapClassPath;
	var int dItemId;
};

var config array<CustomizedWeap>	CustomizedWeaps;

simulated function PreBeginPlay()
{
	local CustomizedWeap instance;
	
	instance.DefClassPath="HealingExtend.WeapDef_HMT401";
	instance.WeapClassPath="HealingExtend.Weap_HMT401";
	instance.dItemId=-1;
	CustomizedWeaps.AddItem(instance);
	
	instance.DefClassPath="HealingExtend.WeapDef_HMT201";
	instance.WeapClassPath="HealingExtend.Weap_HMT201";
	instance.dItemId=-1;
	CustomizedWeaps.AddItem(instance);
	
	ForEach CustomizedWeaps(instance)
		`log("[HE_TraderManager::PreBeginPlay]CustomizedWeaps="$instance.WeapClassPath);
		
	SaveConfig();
	
	super.PreBeginPlay();
}

function StartSyncItem()
{
	`log("[HE_TraderManager::StartSyncItem]StartSyncItem Called.");
	if(WorldInfo.NetMode != NM_Standalone)
		CreateWeapon();
	SetTimer(1.f, True, nameof(ClientSetSaleItems));
}

reliable client function ClientSetSaleItems()
{
	//If it's synchronized between client and server
	if(CreateWeapon())
	{
		ClearTimer(nameof(ClientSetSaleItems));
	}
}

//Create a customized weapon's STraderItem information
//NOTIFICATION: Client side needs time to replicate the default SaleItems
//				Use WorldInfo.GRI to access GRI
simulated function bool CreateWeapon()
{
	local KFGameReplicationInfo		vKFGRI;
	local STraderItem				CustomizedTI, item;
	local int						IdSet;
	local class<KFWeaponDefinition> WeaponDef;
	local class<KFWeapon>			WeaponClass;
	local CustomizedWeap			TIClass;
	
	//`log("[HE_TraderManager]CreateWeapon Called.");
	if(WorldInfo.GRI == None)
	{
		`log("[HE_TraderManager::CreateWeapon]WARNING: Accessed None GRI...");
		return False;
	}
		
	vKFGRI=KFGameReplicationInfo(WorldInfo.GRI);
	
	if(vKFGRI.TraderItems.SaleItems.Length <= 0)
	{
		`log("[HE_TraderManager::CreateWeapon]Waiting for SalesItem to be replicated...");
		return False;
	}
	
	// find highest ItemID in use
	ForEach vKFGRI.TraderItems.SaleItems(item)
		if(IdSet < item.ItemID)
			IdSet = item.ItemID;
	`log("[HE_TraderManager::CreateWeapon]Highest Item ID = "$IdSet);
	
	ForEach CustomizedWeaps(TIClass)
	{
		CustomizedTI.WeaponDef=none;
		CustomizedTI.BlocksRequired=99;
		
		WeaponDef=class<KFWeaponDefinition>(DynamicLoadObject(TIClass.DefClassPath,class'Class'));
		if( WeaponDef == none )
		{
			`log("[HE_TraderManager::CreateWeapon]WARNING: Find no WeaponDef, return...");
			return False;
		}

		WeaponClass=class<KFWeapon>(DynamicLoadObject(TIClass.WeapClassPath,class'Class'));
		if( WeaponClass == none )
		{
			`log("[HE_TraderManager::CreateWeapon]WARNING: Find no WeaponClass, return...");
			return False;
		}
		
		if(vKFGRI.TraderItems.SaleItems.Find('ClassName', WeaponClass.Name) != -1)
			return True;
		
		CustomizedTI.WeaponDef=WeaponDef;
		CustomizedTI.ClassName=WeaponClass.Name;
		`log("[HE_TraderManager::CreateWeapon]Customized Trader Item has been inited, following shows the details--");
		`log("[HE_TraderManager::CreateWeapon]WeaponClass.Name = "$CustomizedTI.ClassName);

		if( class<KFWeap_DualBase>(WeaponClass) != none && class<KFWeap_DualBase>(WeaponClass).Default.SingleClass != none )
			CustomizedTI.SingleClassName=class<KFWeap_DualBase>(WeaponClass).Default.SingleClass.Name;
		else
			CustomizedTI.SingleClassName='';

		if( WeaponClass.Default.DualClass != none )
			CustomizedTI.DualClassName=WeaponClass.Default.DualClass.Name;
		else
			CustomizedTI.DualClassName='';

		CustomizedTI.AssociatedPerkClasses=WeaponClass.Static.GetAssociatedPerkClasses();

		CustomizedTI.MagazineCapacity=WeaponClass.Default.MagazineCapacity[0];
		CustomizedTI.InitialSpareMags=WeaponClass.Default.InitialSpareMags[0];
		CustomizedTI.MaxSpareAmmo=WeaponClass.Default.SpareAmmoCapacity[0];
		CustomizedTI.InitialSecondaryAmmo=WeaponClass.Default.InitialSpareMags[1]*WeaponClass.Default.MagazineCapacity[1];
		CustomizedTI.MaxSecondaryAmmo=WeaponClass.Default.SpareAmmoCapacity[1];

		CustomizedTI.BlocksRequired=WeaponClass.Default.InventorySize;
		WeaponClass.Static.SetTraderWeaponStats(CustomizedTI.WeaponStats);

		CustomizedTI.InventoryGroup=WeaponClass.Default.InventoryGroup;
		CustomizedTI.GroupPriority=WeaponClass.Default.GroupPriority;

		CustomizedTI.TraderFilter=WeaponClass.Static.GetTraderFilter();
		CustomizedTI.AltTraderFilter=WeaponClass.Static.GetAltTraderFilter();
	
		IdSet++;
		CustomizedTI.ItemID=IdSet;

		//Add weap to trader
		vKFGRI.TraderItems.SaleItems.AddItem(CustomizedTI);
		`log("[HE_TraderManager:::CreateWeapon]Cutomized Trader Item has been added into SalesItems::"$IdSet$" "$vKFGRI.TraderItems.SaleItems[IdSet].ClassName);
	}
	
	`log("[HE_TraderManager::CreateWeapon]ACTION: Start Setting Items Info...");
	vKFGRI.TraderItems.SetItemsInfo(vKFGRI.TraderItems.SaleItems);
	
	return True;
}

defaultproperties
{	
	RemoteRole = ROLE_SimulatedProxy
}