#if defined _store_included
	#endinput
#endif
#define _store_included

//new g_cvarChatTag = -1;
//#define CHAT_TAG g_eCvars[g_cvarChatTag][sCache]

#define ITEM_NAME_LENGTH 64
#define STORE_MAX_ITEMS 2048
#define STORE_MAX_HANDLERS 64
#define STORE_MAX_PLANS 8
#define STORE_MAX_SLOTS 4

enum Item_Plan
{
	String:szName[ITEM_NAME_LENGTH],
	iPrice,
	iTime
}

enum Store_Item
{
	String:szUniqueId[PLATFORM_MAX_PATH],
	String:szShortcut[64],
	iId,
	iParent,
	iHandler,
	iFlagBits,
	iData,
	iPlans,
	bool:bBuyable,
	bool:bIgnoreVIP,
	Handle:hAttributes
}

enum Type_Handler
{
	String:szType[64],
	String:szUniqueKey[32],
	bool:bEquipable,
	bool:bRaw,
	Handle:hPlugin,
	Function:fnMapStart,
	Function:fnReset,
	Function:fnConfig,
	Function:fnUse,
	Function:fnRemove
}

enum Client_Item
{
	iUniqueId,
	bool:bSynced,
	bool:bDeleted,
	iDateOfPurchase,
	iDateOfExpiration,
	iPriceOfPurchase,
}

native int Store_RegisterHandler(String:type[], String:uniquekey[], Function:mapstart, Function:reset, Function:config, Function:use, Function:remove, bool:equipable = true, bool:raw = false);
native int Store_RegisterMenuHandler(String:identifier[], Function:menu, Function:handler);
native void Store_SetDataIndex(itemid, index);
native int Store_GetDataIndex(itemid);
native int Store_GetEquippedItem(client, String:type[], slot=0);
native bool Store_IsClientLoaded(client);
native void Store_DisplayPreviousMenu(client);
native void Store_SetClientMenu(client, num);
native int Store_GetClientCredits(client);
native void Store_SetClientCredits(client, credits);
native bool Store_IsClientVIP(client);
native bool Store_IsItemInBoughtPackage(client, itemid, uid=-1);
native bool Store_ShouldConfirm();
native void Store_DisplayConfirmMenu(client, String:title[], Function:callback, data);
native int Store_GetItem(int itemid, any output[sizeof(Store_Item)]);
native void Store_GetHandler(int index, any output[sizeof(Type_Handler)]);
native void Store_GiveItem(client, itemid, purchase=0, expiration=0, price=0);
native void Store_RemoveItem(client, itemid);
native bool Store_GetClientItem(int client, int itemid, any output[sizeof(Client_Item)]);
native int Store_GetClientTarget(client);
native int Store_GiveClientItem(client, recipient, itemid);
native bool Store_HasClientItem(client, itemid);
native int Store_IterateEquippedItems(client, &start, bool:attributes=false);

forward void Store_OnClientModelChanged(client, String:model[]);

public Extension:__ext_store_sm =
{
	name = "Store - The Resurrection",
	file = "store_sm.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
	required = 0,
};
