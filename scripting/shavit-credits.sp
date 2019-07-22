#include <sourcemod>
#include <sdktools>
#include <store>
#include <shavit>
#include <autoexecconfig>
#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.3.4"
chatstrings_t gS_ChatStrings;
public Plugin myinfo = 
{
	name = "[shavit] Credits | Zephyrus Store", 
	author = "Farhannz, Modified by SaengerItsWar and totenfluch", 
	description = "Gives Zephyrus Store Credits for records", 
	version = PLUGIN_VERSION, 
	url = "https://deadnationgaming.eu/"
};

ConVar g_cvNormalEnabled;
int g_iNormalEnabled;
ConVar g_cvWREnabled;
int g_iWREnabled;
ConVar g_cvEnabledPb;
int g_iPBEnabled;
ConVar g_cvT1Enabled;
int g_iT1Enabled;
ConVar g_cvNormalAmount;
int g_iNormalAmount;
ConVar g_cvWrAmount;
int g_iWrAmount;
ConVar g_cvPBAmount;
int g_iPBAmount;
ConVar g_cvBNormalEnabled;
int g_iBNormalEnabled;
ConVar g_cvBWREnabled;
int g_iBWREnabled;
ConVar g_cvEnabledBPb;
int g_iBPBEnabled;
ConVar g_cvNormalBAmount;
int g_iNormalBAmount;
ConVar g_cvWrBAmount;
int g_iWrBAmount;
ConVar g_cvBPbAmount;
int g_iBPbAmount;

char g_cMap[160];
int g_iTier;
int g_iStyle;
float g_fPB;

public void OnPluginStart()
{
	
	AutoExecConfig_SetFile("shavit-credits");
	AutoExecConfig_SetCreateFile(true);
	CreateConVar("shavit_credtis_version", PLUGIN_VERSION, "Kxnrl-Store : Shavit Credits for records", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_cvNormalEnabled = AutoExecConfig_CreateConVar("credits_enable_normal", "1", "Enable Store credits given for finishing a map?", 0, true, 0.0, true, 1.0);
	g_cvWREnabled = AutoExecConfig_CreateConVar("credits_enable_wr", "1", "Enable Store credits given for greaking the map Record?", 0, true, 0.0, true, 1.0);
	g_cvEnabledPb = AutoExecConfig_CreateConVar("credits_enable_pb", "1", "Enable Store credits given for breaking the map Personal Best?", 0, true, 0.0, true, 1.0);
	g_cvT1Enabled = AutoExecConfig_CreateConVar("credits_enable_t1", "0", "Enable/Disable given credits for Tier 1. This has no effect on WRs and PBs!", 0, true, 0.0, true, 1.0);
	g_cvNormalAmount = AutoExecConfig_CreateConVar("credits_amount_normal", "10", "How many points should be given for finishing a Map?(will be claculated per Tier(amount_normal*Tier))", 0, true, 1.0, false);
	g_cvWrAmount = AutoExecConfig_CreateConVar("credits_amount_wr", "25", "How many points should be given for breaking a Map record?(will be calculated per Tier(amount_wr*Tier))", 0, true, 1.0, false);
	g_cvPBAmount = AutoExecConfig_CreateConVar("credits_amount_pb", "10", "How many point should be given for breaking the own Personal Best?(will be calculated per Tier(amount_pb*Tier))", 0, true, 1.0, false);
	g_cvBNormalEnabled = AutoExecConfig_CreateConVar("credits_enable_normal_bonus", "0", "Enable Store credits given for finishing a map?", 0, true, 0.0, true, 1.0);
	g_cvBWREnabled = AutoExecConfig_CreateConVar("credits_enable_wr_bonus", "0", "Enable Store credits given for greaking the map Record?", 0, true, 0.0, true, 1.0);
	g_cvEnabledBPb = AutoExecConfig_CreateConVar("credits_enable_pb_bonus", "0", "Enable Store credits given for breaking the map Personal Best?", 0, true, 0.0, true, 1.0);
	g_cvNormalBAmount = AutoExecConfig_CreateConVar("credits_amount_normal_bonus", "10", "How many points should be given for finishing a Map?", 0, true, 1.0, false);
	g_cvWrBAmount = AutoExecConfig_CreateConVar("credits_amount_wr_bonus", "25", "How many points should be given for breaking a Map record?", 0, true, 1.0, false);
	g_cvBPbAmount = AutoExecConfig_CreateConVar("credits_amount_pb_bonus", "10", "How many point should be given for breaking the own Personal Best?", 0, true, 1.0, false);
	
	HookConVarChange(g_cvNormalEnabled, OnConVarChange);
	HookConVarChange(g_cvWREnabled, OnConVarChange);
	HookConVarChange(g_cvEnabledPb, OnConVarChange);
	HookConVarChange(g_cvT1Enabled, OnConVarChange);
	HookConVarChange(g_cvNormalAmount, OnConVarChange);
	HookConVarChange(g_cvWrAmount, OnConVarChange);
	HookConVarChange(g_cvPBAmount, OnConVarChange);
	HookConVarChange(g_cvBNormalEnabled, OnConVarChange);
	HookConVarChange(g_cvBWREnabled, OnConVarChange);
	HookConVarChange(g_cvEnabledBPb, OnConVarChange);
	HookConVarChange(g_cvNormalBAmount, OnConVarChange);
	HookConVarChange(g_cvWrBAmount, OnConVarChange);
	HookConVarChange(g_cvBPbAmount, OnConVarChange);
	
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}

public void OnConfigsExecuted() {
	g_iNormalEnabled = GetConVarInt(g_cvNormalEnabled);
	g_iWREnabled = GetConVarInt(g_cvWREnabled);
	g_iPBEnabled = GetConVarInt(g_cvEnabledPb);
	g_iT1Enabled = GetConVarInt(g_cvT1Enabled);
	g_iNormalAmount = GetConVarInt(g_cvNormalAmount);
	g_iWrAmount = GetConVarInt(g_cvWrAmount);
	g_iPBAmount = GetConVarInt(g_cvPBAmount);
	g_iBNormalEnabled = GetConVarInt(g_cvBNormalEnabled);
	g_iBWREnabled = GetConVarInt(g_cvBWREnabled);
	g_iBPBEnabled = GetConVarInt(g_cvEnabledBPb);
	g_iNormalBAmount = GetConVarInt(g_cvNormalBAmount);
	g_iWrBAmount = GetConVarInt(g_cvWrBAmount);
	g_iBPbAmount = GetConVarInt(g_cvBPbAmount);
}

public void OnConVarChange(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_iNormalEnabled = GetConVarInt(g_cvNormalEnabled);
	g_iWREnabled = GetConVarInt(g_cvWREnabled);
	g_iPBEnabled = GetConVarInt(g_cvEnabledPb);
	g_iT1Enabled = GetConVarInt(g_cvT1Enabled);
	g_iNormalAmount = GetConVarInt(g_cvNormalAmount);
	g_iWrAmount = GetConVarInt(g_cvWrAmount);
	g_iPBAmount = GetConVarInt(g_cvPBAmount);
	g_iBNormalEnabled = GetConVarInt(g_cvBNormalEnabled);
	g_iBWREnabled = GetConVarInt(g_cvBWREnabled);
	g_iBPBEnabled = GetConVarInt(g_cvEnabledBPb);
	g_iNormalBAmount = GetConVarInt(g_cvNormalBAmount);
	g_iWrBAmount = GetConVarInt(g_cvWrBAmount);
	g_iBPbAmount = GetConVarInt(g_cvBPbAmount);
}

public void OnMapStart() {
	GetCurrentMap(g_cMap, sizeof(g_cMap));
	GetMapDisplayName(g_cMap, g_cMap, sizeof(g_cMap));
	g_iTier = Shavit_GetMapTier(g_cMap);
}

public void Shavit_OnChatConfigLoaded()
{
	Shavit_GetChatStrings(sMessagePrefix, gS_ChatStrings.sPrefix, sizeof(chatstrings_t::sPrefix));
	Shavit_GetChatStrings(sMessageText, gS_ChatStrings.sText, sizeof(chatstrings_t::sText));
	Shavit_GetChatStrings(sMessageWarning, gS_ChatStrings.sWarning, sizeof(chatstrings_t::sWarning));
	Shavit_GetChatStrings(sMessageVariable, gS_ChatStrings.sVariable, sizeof(chatstrings_t::sVariable));
	Shavit_GetChatStrings(sMessageVariable2, gS_ChatStrings.sVariable2, sizeof(chatstrings_t::sVariable2));
	Shavit_GetChatStrings(sMessageStyle, gS_ChatStrings.sStyle, sizeof(chatstrings_t::sStyle));
}

public Action Shavit_OnStart(int client, int track) {
	g_iStyle = Shavit_GetBhopStyle(client);
	g_fPB = Shavit_GetClientPB(client, g_iStyle, track);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int strafes, float sync, int track) {
	
	char sStyleSpecialString[sizeof(stylestrings_t::sSpecialString)];
	Shavit_GetStyleStrings(style, sSpecialString, sStyleSpecialString, sizeof(sStyleSpecialString));

	if (StrContains(sStyleSpecialString, "segments") != -1)
    		return;
	
	if (g_iNormalEnabled == 1) {
		if (g_iT1Enabled == 1 || g_iTier != 1) {
			
			if(track == 0){
				int iCredits = g_iNormalAmount * g_iTier;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits);
				Shavit_PrintToChat(client, "You have earned %s%d%s credits for finishing this map.", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
			
			else if(g_iBNormalEnabled == 1){
				int iCredits = g_iNormalBAmount;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits);
				Shavit_PrintToChat(client, "You have earned %s%d%s credits for finishing the Bonus of this map.", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
		}
		
	}
	
	if (g_iPBEnabled == 1) {
		if (time < g_fPB) {
			if(track == 0){
				int iCredits = g_iPBAmount * g_iTier;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits);
				Shavit_PrintToChat(client, "You have earned %s%d%s credits for breaking your Personal Best.", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
			
			else if(g_iBPBEnabled == 1){
				int iCredits = g_iBPbAmount;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits);
				Shavit_PrintToChat(client, "You have earned %s%d%s credits for breaking your bonus Personal Best.", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
			}
			
			
		}
	}
	
}
public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int strafes, float sync, int track) {
	
	char sStyleSpecialString[sizeof(stylestrings_t::sSpecialString)];
	Shavit_GetStyleStrings(style, sSpecialString, sStyleSpecialString, sizeof(sStyleSpecialString));

	if (StrContains(sStyleSpecialString, "segments") != -1)
    		return;
		
	if (g_iWREnabled == 1) {
		if(track == 0){
			int iCredits = g_iWrAmount * g_iTier;
		
			Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits);
			Shavit_PrintToChat(client, "You have earned %s%d%s credits for breaking the WR.", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
		}
		
		else if(g_iBWREnabled == 1){
			int iCredits = g_iWrBAmount;
		
			Store_SetClientCredits(client, Store_GetClientCredits(client) + iCredits);
			Shavit_PrintToChat(client, "You have earned %s%d%s credits for breaking the Bonus WR.", gS_ChatStrings.sVariable, iCredits, gS_ChatStrings.sText);
		}
	}
}
