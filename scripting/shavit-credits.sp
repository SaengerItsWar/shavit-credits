#include <sourcemod>
#include <sdktools>
#include <store>
#include <shavit>
#include <autoexecconfig>

#define PLUGIN_VERSION "1.2.2"
public Plugin myinfo = 
{
	name = "[shavit] Credits | Zephyrus Store", 
	author = "Farhannz, Modified by Saengerkrieg12", 
	description = "Gives Zephyrus Store Credits on map finish and breaking records", 
	version = PLUGIN_VERSION, 
	url = "https://deadnationgaming.eu/"
};

ConVar g_cvNormalEnabled;
int g_iNormalEnabled
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

public void OnPluginStart() {
	AutoExecConfig_SetFile("shavit_credits");
	AutoExecConfig_SetCreateFile(true);
	
	CreateConVar("shavit_credits_version", PLUGIN_VERSION, "Zephyrus-Store : Shavit Credits Map Finish", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_cvNormalEnabled = AutoExecConfig_CreateConVar("credits_enable_normal", "1", "Store money give for map finish is enabled?", 0, true, 0.0, true, 1.0);
	g_cvWREnabled = AutoExecConfig_CreateConVar("credits_enable_wr", "1", "Store money given for map World Record is enabled?", 0, true, 0.0, true, 1.0);
	g_cvEnabledPb = AutoExecConfig_CreateConVar("credits_enable_pb", "1", "Store money given for map Personal Best is enabled?", 0, true, 0.0, true, 1.0);
	g_cvT1Enabled = AutoExecConfig_CreateConVar("credits_enable_t1", "1", "Enable/Disable give credits for Tier 1 Has no effect on WRs and PBs!", 0, true, 0.0, true, 1.0);
	g_cvNormalAmount = AutoExecConfig_CreateConVar("credits_amount_normal", "10", "Amount of credits are given on map finish.", 0, true, 1.0, false);
	g_cvWrAmount = AutoExecConfig_CreateConVar("credits_amount_wr", "25", "Amount of credits are given on breaking world records.", 0, true, 1.0, false);
	g_cvPBAmount = AutoExecConfig_CreateConVar("credits_amount_pb", "10", "Amount of credits are given on breaking your personal best.", 0, true, 1.0, false);
	
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

public void OnMapStart() {
	GetCurrentMap(g_cMap, 160);
	GetMapDisplayName(g_cMap, g_cMap, 160);
	g_iTier = Shavit_GetMapTier(g_cMap);
}

public Action Shavit_OnStart(int client, int track) {
	g_iStyle = Shavit_GetBhopStyle(client);
	g_fPB = Shavit_GetClientPB(client, g_iStyle, track);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int track) {
	if (g_iNormalEnabled == 1) {
		if (g_iT1Enabled == 1 || g_iTier != 1) {
			int fcredits = GetConVarInt(g_cvNormalAmount) * g_iTier;
			
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
			PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for finishing this map.", fcredits);
		}
	}
	
	if (g_iPBEnabled == 1) {
		if (time < g_fPB) {
			
			int fcredits = GetConVarInt(g_cvPBAmount) * g_iTier;
			
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
			PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for breaking your Personal Best.", fcredits);
		}
	}
	
}
public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int track) {
	if (g_iWREnabled == 1) {
		int fcredits = GetConVarInt(g_cvWrAmount) * g_iTier;
		
		Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
		PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for break the world records.", fcredits);
	}
}
