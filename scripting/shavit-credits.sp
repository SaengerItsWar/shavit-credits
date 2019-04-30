#include <sourcemod>
#include <sdktools>
#include <store>
#include <shavit>

#define PLUGIN_VERSION "1.2.2"
public Plugin myinfo = 
{
	name = "[shavit] Credits | Zephyrus Store",
	author = "Farhannz, Modified by Saengerkrieg12",
	description = "Gives Zephyrus Store Credits on map finish and breaking records",
	version = PLUGIN_VERSION,
	url = "https://deadnationgaming.eu/"
};
Handle gh_enabled_normal;
Handle gh_enabled_wr;
Handle gh_enabled_pb;
Handle gh_amount_normal;
Handle gh_amount_wr;
Handle gh_amount_pb;
Handle gh_enabled_t1;
char gS_Map[160];
int iTier;
int istyle;
float fpb;
int nr_enabled;
int wr_enabled;
int pb_enabled;
int t1_enabled;

public void OnPluginStart()
{
	CreateConVar("shavit_creds_version", PLUGIN_VERSION, "Zephyrus-Store : Shavit Credits Map Finish", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	gh_enabled_normal = CreateConVar("credits_enable_normal", "1", "Store money give for map finish is enabled?", 0, true, 0.0, true, 1.0);
	gh_enabled_wr = CreateConVar("credits_enable_wr", "1", "Store money given for map World Record is enabled?", 0, true, 0.0, true, 1.0);
	gh_enabled_pb = CreateConVar("credits_enable_pb", "1", "Store money given for map Personal Best is enabled?", 0, true, 0.0, true, 1.0);
	gh_enabled_t1 = CreateConVar("credits_enable_t1", "1", "Enable/Disable give credits for Tier 1 Has no effect on WRs and PBs!", 0, true, 0.0, true, 1.0);
	gh_amount_normal = CreateConVar("credits_amount_normal", "10", "Amount of credits are given on map finish.", 0, true, 1.0, false);
	gh_amount_wr = CreateConVar("credits_amount_wr", "25", "Amount of credits are given on breaking world records.", 0, true, 1.0, false);
	gh_amount_pb = CreateConVar("credits_amount_pb", "10", "Amount of credits are given on breaking your personal best.", 0, true, 1.0, false);
	
	AutoExecConfig(true, "shavit-credits");
	
	nr_enabled = GetConVarInt(gh_enabled_normal);
	wr_enabled = GetConVarInt(gh_enabled_wr);
	pb_enabled = GetConVarInt(gh_enabled_pb);
	t1_enabled = GetConVarInt(gh_enabled_t1);
	
}

public void OnMapStart()
{
	GetCurrentMap(gS_Map, 160);
	GetMapDisplayName(gS_Map, gS_Map, 160);
	iTier = Shavit_GetMapTier(gS_Map);		
}

public Action Shavit_OnStart(int client, int track)
{
	istyle = Shavit_GetBhopStyle(client);
	fpb = Shavit_GetClientPB(client, istyle, track);
}

public void Shavit_OnFinish(int client, int style, float time, int jumps, int track)
{
	
	if(nr_enabled == 1)
	{
		if(t1_enabled == 1 || iTier != 1)
		{
			int fcredits = GetConVarInt(gh_amount_normal)*iTier;
	
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
			PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for finishing this map.", fcredits);
		}
	}
	
	if(pb_enabled == 1)
	{	
			if(time<fpb){
			
				int fcredits = GetConVarInt(gh_amount_pb)*iTier;
			
				Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
				PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for breaking your Personal Best.", fcredits);
			}
	}
	
}
public void Shavit_OnWorldRecord(int client, int style, float time, int jumps, int track)
{
	if(wr_enabled == 1)
	{
			int fcredits = GetConVarInt(gh_amount_wr)*iTier;
	
			Store_SetClientCredits(client, Store_GetClientCredits(client) + fcredits);
			PrintToChat(client, "[\x04Store\x01] You have earned \x04%d\x01 credits for break the world records.", fcredits);
	}
}
