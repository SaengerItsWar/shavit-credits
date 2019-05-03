#include <sourcemod>
#include <sdktools>
#include <store>
#include <shavit>
#include <autoexecconfig>
#include <multicolors>
#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.3.0"
public Plugin myinfo = 
{
	name = "[shavit] Credits | Zephyrus Store", 
	author = "Farhannz, Modified by Saengerkrieg12 and totenfluch", 
	description = "Gives Zephyrus Store Credits on map finish and breaking records", 
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
	g_cvT1Enabled = AutoExecConfig_CreateConVar("credits_enable_t1", "1", "Enable/Disable given credits for Tier 1. This has no effect on WRs and PBs!", 0, true, 0.0, true, 1.0);
	g_cvNormalAmount = AutoExecConfig_CreateConVar("credits_amount_normal", "10", "How many points should be given for finishing a Map?(will be claculated per Tier(amount_normal*Tier))", 0, true, 1.0, false);
	g_cvWrAmount = AutoExecConfig_CreateConVar("credits_amount_wr", "25", "How many points should be given for breaking a Map record?(will be calculated per Tier(amount_wr*Tier))", 0, true, 1.0, false);
	g_cvPBAmount = AutoExecConfig_CreateConVar("credits_amount_pb", "10", "How many point should be given for breaking the own Personal Best?(will be calculated per Tier(amount_pb*Tier))", 0, true, 1.0, false);
	
	HookConVarChange(g_cvNormalEnabled, OnConVarChange);
	HookConVarChange(g_cvWREnabled, OnConVarChange);
	HookConVarChange(g_cvEnabledPb, OnConVarChange);
	HookConVarChange(g_cvT1Enabled, OnConVarChange);
	HookConVarChange(g_cvNormalAmount, OnConVarChange);
	HookConVarChange(g_cvWrAmount, OnConVarChange);
	HookConVarChange(g_cvPBAmount, OnConVarChange);
	
	
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
}

public void OnConVarChange(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_iNormalEnabled = GetConVarInt(g_cvNormalEnabled);
	g_iWREnabled = GetConVarInt(g_cvWREnabled);
	g_iPBEnabled = GetConVarInt(g_cvEnabledPb);
	g_iT1Enabled = GetConVarInt(g_cvT1Enabled);
	g_iNormalAmount = GetConVarInt(g_cvNormalAmount);
	g_iWrAmount = GetConVarInt(g_cvWrAmount);
	g_iPBAmount = GetConVarInt(g_cvPBAmount);
}

public void OnMapStart() {
	GetCurrentMap(g_cMap, sizeof(g_cMap[]));
	GetMapDisplayName(g_cMap, g_cMap, sizeof(g_cMap[]));
	g_iTier = Shavit_GetMapTier(g_cMap);
}

public Action Shavit_OnStart(int client, int track) {
	g_iStyle = Shavit_GetBhopStyle(client);
	g_fPB = Shavit_GetClientPB(client, g_iStyle, track);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int track) {
	if (g_iNormalEnabled == 1) {
		if (g_iT1Enabled == 1 || g_iTier != 1) {
			int fcredits = g_iNormalAmount * g_iTier;
			
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits, "[shavit] Credits for finishing a map");
			CPrintToChat(client, "[{green}Store{default}] You have earned {green}%d{default} credits for finishing this map.", fcredits);
		}
	}
	
	if (g_iPBEnabled == 1) {
		if (time < g_fPB) {
			
			int fcredits = g_iPBAmount * g_iTier;
			
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits, "[Shavit] Credits for breaking the own Personal Best");
			CPrintToChat(client, "[{green}Store{default}] You have earned {green}%d{default} credits for breaking your Personal Best.", fcredits);
		}
	}
	
}
public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int track) {
	if (g_iWREnabled == 1) {
		int fcredits = g_iWrAmount * g_iTier;
		
		Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits, "[Shavit] Credits for breaking a map record");
		CPrintToChat(client, "[{green}Store{default}] You have earned {green}%d{default} credits for breaking the world records.", fcredits);
	}
}