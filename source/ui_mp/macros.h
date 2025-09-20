/*
Text items are aligned to left bottom corner of text

ITEM_ALIGN_LEFT:
				Text location
				+
ITEM_ALIGN_CENTER:
	   Text aligned to center
				+
ITEM_ALIGN_RIGHT:
	 Text location
				 +

doubleclick
*/

#define ITEM_TEXT(textstring, x, y, fontsize, txtalign, fontcolor) \
itemDef \
{ \
	rect			x y 0 0 0 0 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	decoration \
}

#define ITEM_TEXT_DVAR(textstring, x, y, fontsize, txtalign, fontcolor, dvartotest, dvarshowhide) \
itemDef \
{ \
	rect			x y 0 0 0 0 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvartest		dvartotest \
	dvarshowhide \
	decoration \
}

#define ITEM_DVAR(cvar, x, y, fontsize, txtalign, fontcolor) \
itemDef \
{ \
	rect			0 0 200 50 0 0 \
	origin			x y \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvar			cvar \
	decoration \
}

#define ITEM_DVAR_DVAR(cvar, x, y, fontsize, txtalign, fontcolor, dvartotest, dvarshowhide) \
itemDef \
{ \
	rect			0 0 200 50 0 0 \
	origin			x y \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvar			cvar \
	dvartest		dvartotest \
	dvarshowhide \
	decoration \
}

#define ITEM_BAR_BOTTOM_BUTTON_DVAR(textstring, x, w, dvartotest, dvarshowhide, actions)  \
itemDef \
{ \
	visible			1 \
	rect			0 0 w 24 0 0 \
	origin			x 438 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textaligny		18 \
	dvartest		dvartotest \
	dvarshowhide \
	action \
	{ \
		play "mouse_click"; \
		actions ; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
}

#define ITEM_BAR_BOTTOM_BUTTON_DVAR_DISABLED(textstring, x, w, dvartotest, dvarshowhide)  \
itemDef \
{ \
	visible			1 \
	rect			0 0 w 24 0 0 \
	origin			x 438 \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textaligny		18 \
	dvartest		dvartotest \
	dvarshowhide \
}

#define ITEM_BAR_BOTTOM_BUTTON(textstring, x, w, actions)  \
itemDef \
{ \
	visible			1 \
	rect			0 0 w 24 0 0 \
	origin			x 438 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textaligny		18 \
	action \
	{ \
		play "mouse_click"; \
		actions ; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
}


#define DRAW_MAP_BACKGROUND_IF_BLACKOUT \
itemDef \
{ \
	rect 			-128 0 896 480 0 0 \
	visible 		1 \
	backcolor 		1 1 1 1 \
	style 			WINDOW_STYLE_FILLED \
	background 		"$levelBriefing" \
	dvartest 		"ui_blackout" \
	showDvar		{ "1" } \
	decoration \
}

//0.149 .227 0.294 .5
#define DRAW_BLUISH_BACKGROUND \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			0 0 640 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	backcolor		0.083 .129 0.168 .5 \
	visible			1 \
	decoration \
}

#define	DRAW_GRADIENT_LEFT_TO_RIGHT \
itemDef \
{ \
	style			WINDOW_STYLE_SHADER \
	rect			-128 0 896 480 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN \
	background		"gradient" \
	visible			1 \
	decoration \
}

#define	DRAW_GRADIENT_FOR_SUBMENU(x, y, w, h, alpha) \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			x y w h 0 0 \
	backcolor		0 0 0 alpha \
	visible			1 \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			x y 1 h 0 0 \
	backcolor		.631 .666 .698 .2 \
	visible			1 \
	decoration \
} \

#define DRAW_BARS \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 0 896 60 0 0 \
	backcolor		0.0045 .005 0.0053 .95 \
	visible			1 \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 435 896 45 0 0 \
	backcolor		0.0045 .005 0.0053 .95 \
	visible			1 \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 60 896 1 0 0 \
	backcolor		.631 .666 .698 .2 \
	visible			1 \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			-128 435 896 1 0 0 \
	backcolor		.631 .666 .698 .2 \
	visible			1 \
	decoration \
}

#define ITEM_TEXT_HEADING(teamname) \
itemDef \
{ \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	origin			40 60 \
	forecolor		1 1 1 1 \
	text			teamname \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_HEADER_SIZE \
	decoration \
}




#define ORIGIN_CHOICE1	60 84
#define ORIGIN_CHOICE2	60 108
#define ORIGIN_CHOICE3	60 132
#define ORIGIN_CHOICE4	60 156
#define ORIGIN_CHOICE5	60 180
#define ORIGIN_CHOICE6	60 204
#define ORIGIN_CHOICE7	60 228
#define ORIGIN_CHOICE8	60 252
#define ORIGIN_CHOICE9	60 276
#define ORIGIN_CHOICE10	60 300
#define ORIGIN_CHOICE11	60 324
#define ORIGIN_CHOICE12	60 348
#define ORIGIN_CHOICE13	60 372

#define ITEM_BUTTON(origin_choice, textstring, dofocus, doaction) \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			origin_choice \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	action \
	{ \
		play "mouse_click"; \
		doaction; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
		dofocus; \
	} \
}


#define ITEM_BUTTON_ONDVAR(origin_choice, textstring, dvarstring, dvarvisible, dofocus, doaction) \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			origin_choice \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		dvarstring \
	dvarvisible \
	action \
	{ \
		play "mouse_click"; \
		doaction; \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
		dofocus; \
	} \
}

#define ITEM_BUTTON_ONDVAR_DISABLED(origin_choice, textstring, dvarstring, dvarvisible, dofocus) \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			origin_choice \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		dvarstring \
	dvarvisible \
	onFocus \
	{ \
		play "mouse_over"; \
		dofocus; \
	} \
	decoration \
}






#define ORIGIN_WEAPONIMAGE			310 110
#define ORIGIN_GRENADESLOT1			310 170
#define ORIGIN_GRENADESLOT2			330 170
#define ORIGIN_USEDBY						310 250
#define ORIGIN_USEDBY2					302 263

#define ITEM_WEAPON_SMOKE(originpos, stringname, weaponname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, weaponclass) \
ITEM_WEAPON(originpos, stringname, weaponname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, weaponclass) \
itemDef \
{ \
	name			weaponimage \
	visible 		0 \
	rect			0 0 32 32 0 0 \
	origin			ORIGIN_GRENADESLOT2 \
	style			WINDOW_STYLE_SHADER \
	background		"hud_us_smokegrenade_C" \
	decoration \
}

#define ITEM_WEAPON(originpos, stringname, weaponname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, weaponclass) \
itemDef \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			stringtext \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "1" } \
	action \
	{ \
		play "mouse_click"; \
		doaction \
	} \
	onFocus \
	{ \
		HIDE_ALL \
		play "mouse_over"; \
		focusaction \
	} \
} \
itemDef  \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			"" \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "2" } \
	onFocus \
	{ \
		HIDE_ALL \
		focusaction \
	} \
} \
itemDef  \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		GLOBAL_DISABLED_COLOR \
	type			ITEM_TYPE_BUTTON \
	text			stringtext \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "2" } \
	decoration \
} \
 \
itemDef  \
{ \
	name			stringname \
	visible			1 \
	rect			0 0 128 24 0 0 \
	origin			originpos \
	forecolor		.95 .84 .7 1  \
	type			ITEM_TYPE_BUTTON \
	text			stringtext \
	textfont		UI_FONT_NORMAL \
	textscale		GLOBAL_TEXT_SIZE \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		20 \
	dvartest		cvartext \
	showDvar		{ "3" } \
	action \
	{ \
		play "mouse_click"; \
		doaction \
	} \
	onFocus \
	{ \
		HIDE_ALL \
		play "mouse_over"; \
		focusaction \
	} \
} \
 \
itemDef \
{ \
	name			weaponimage \
	visible 		0 \
	rect			0 0 224 112 0 0 \
	origin			ORIGIN_WEAPONIMAGE \
	style			WINDOW_STYLE_SHADER \
	background		weaponimage \
	decoration \
} \
itemDef \
{ \
	name			weaponimage \
	visible 		0 \
	rect			0 0 32 32 0 0 \
	origin			ORIGIN_GRENADESLOT1 \
	style			WINDOW_STYLE_SHADER \
	background		"gfx/icons/hud@" grenadeimage ".tga" \
	decoration \
} \
itemDef  \
{ \
	name			weaponimage \
	visible			0 \
	origin			ORIGIN_USEDBY \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	text 			"Used by:" \
	type			ITEM_TYPE_TEXT \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	dvartest		"ui_weapons_usedby_" weaponname \
	hideDvar		{ "" } \
	decoration \
} \
itemDef  \
{ \
	name			weaponimage \
	visible			0 \
	origin			ORIGIN_USEDBY2 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	text 			" " \
	type			ITEM_TYPE_EDITFIELD \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	dvar			"ui_weapons_usedby_" weaponname  \
	dvartest		"ui_weapons_usedby_" weaponname  \
	hideDvar		{ "" } \
	decoration \
}







#define SERVERINFO_DRAW_OBJECTIVE(objectivetext) \
itemDef \
{ \
	visible			1 \
	rect			0 0 480 75 0 0 \
	origin			60 84 \
	forecolor		1 1 1 1 \
	autowrapped \
	text			objectivetext \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		16 \
	decoration \
}

#define SERVERINFO_DRAW_PARAMETERS \
itemDef \
{ \
	visible			1 \
	rect			0 0 180 110 0 0 \
	origin			160 180 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_left1" \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_RIGHT \
	autowrapped \
	decoration \
} \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 110 0 0 \
	origin			175 180 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_left2" \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	autowrapped \
	decoration \
} \
itemDef \
{ \
	visible			1 \
	rect			0 0 180 110 0 0 \
	origin			390 180 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_right1" \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_RIGHT \
	autowrapped \
	decoration \
} \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 110 0 0 \
	origin			405 180 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_right2" \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_LEFT \
	autowrapped \
	decoration \
}

#define SERVERINFO_DRAW_MOTD \
itemDef \
{ \
	name			"text_motd" \
	visible			1 \
	rect			0 0 480 130 0 0 \
	origin			60 305 \
	forecolor		1 1 1 1 \
	dvar			"ui_motd" \
	textfont		UI_FONT_NORMAL \
	textscale		0.25 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		16 \
	decoration \
} \
itemDef \
{ \
	name			"text_serverversion" \
	visible			1 \
	rect			0 0 480 130 0 0 \
	origin			60 410 \
	forecolor		1 1 1 .4 \
	dvar			"ui_serverversion" \
	textfont		UI_FONT_NORMAL \
	textscale		0.2 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		16 \
	decoration \
}

#define SERVERINFO_DRAW_QUIT \
itemDef \
{ \
	visible 		1 \
	rect			-128 60 896 375 0 0  \
	type 			ITEM_TYPE_BUTTON \
	action \
	{ \
		scriptMenuResponse "close"; \
	} \
}


#define RCON_UPDATE_STATUS execOnDvarStringValue ui_rcon_logged_in 0 "vstr ui_rcon_hash";




#define QUICKMESSAGE_LINE_TEXT(y, textstring, fontcolor)  \
itemDef \
{ \
	name			"window" \
	visible			1 \
	rect			16 y 0 0 0 0 \
	origin			ORIGIN_QUICKMESSAGEWINDOW \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		.24 \
	textaligny		8 \
	textstyle ITEM_TEXTSTYLE_SHADOWED \
	text			textstring \
	decoration \
}

#define QUICKMESSAGE_LINE_TEXT_DVAR(y, textstring, fontcolor, dvarstring, dvarvisible)  \
itemDef \
{ \
	name			"window" \
	visible			1 \
	rect			16 y 0 0 0 0 \
	origin			ORIGIN_QUICKMESSAGEWINDOW \
	forecolor		fontcolor \
	textfont		UI_FONT_NORMAL \
	textscale		.24 \
	textaligny		8 \
	textstyle ITEM_TEXTSTYLE_SHADOWED \
	text			textstring \
	dvartest		dvarstring \
	dvarvisible \
	decoration \
}


#define DVAR_CHECK(textstring, dvartotest, dvarshowhide) \
itemDef \
{ \
	rect 			-128 0 896 480 0 0 \
	visible 		1 \
	backcolor 		1 1 1 1 \
	style 			WINDOW_STYLE_FILLED \
	background 		"$levelBriefing" \
	dvartest		dvartotest \
	dvarshowhide \
	decoration \
} \
itemDef \
{ \
	rect			0 0 200 50 0 0 \
	origin			320 100 \
	type			ITEM_TYPE_TEXT \
	text			textstring \
	visible			1 \
	forecolor		1 0 0 1 \
	textfont		UI_FONT_NORMAL \
	textscale		0.6 \
	textalign		ITEM_ALIGN_CENTER \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvartest		dvartotest \
	dvarshowhide \
	decoration \
}






#define MATCHINFO_BGCOLOR(xywh, bc, cvartest, showhidedvar) \
itemDef \
{ \
  style			WINDOW_STYLE_FILLED \
  rect			xywh 0 0 \
  backcolor		bc \
  visible		1 \
  dvartest		cvartest \
  showhidedvar \
  decoration \
}

#define MATCHINFO_ICON(xy, bg, cvartest, showhidedvar) \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		xy 12 12 0 0 \
	backcolor	1 1 1 1 \
	visible		1 \
	background	bg \
	dvartest	cvartest \
        showhidedvar \
	decoration \
}

#define MATCHINFO(cvar_team1_team, cvar_team2_team, cvar_show, color_allies, color_axis) \
\
	MATCHINFO_BGCOLOR(-131 0 130 15, color_allies, 		cvar_team1_team, showDvar { "american"; "british"; "russian"; })  \
	MATCHINFO_BGCOLOR(-131 0 130 15, color_axis, 		cvar_team1_team, showDvar { "german" })  \
\
	MATCHINFO_BGCOLOR(-131 0 130 14, .1 .1 .1 .55, 		cvar_team1_team, showDvar { "american"; "british"; "russian"; "german" }) \
	MATCHINFO_ICON(-128 1, "hudicon_american", 		cvar_team1_team, showDvar { "american" } ) \
	MATCHINFO_ICON(-128 1, "hudicon_british", 		cvar_team1_team, showDvar { "british" } ) \
	MATCHINFO_ICON(-128 1, "hudicon_russian", 		cvar_team1_team, showDvar { "russian" } ) \
	MATCHINFO_ICON(-128 1, "hudicon_german", 		cvar_team1_team, showDvar { "german" } ) \
\
\
	MATCHINFO_BGCOLOR(1 0 130 15, color_allies, 		cvar_team2_team, showDvar { "american"; "british"; "russian"; }) \
	MATCHINFO_BGCOLOR(1 0 130 15, color_axis, 		cvar_team2_team, showDvar { "german" }) \
\
	MATCHINFO_BGCOLOR(1 0 130 14, .1 .1 .1 .55, 		cvar_team2_team, showDvar { "american"; "british"; "russian"; "german" }) \
	MATCHINFO_ICON(3 1, "hudicon_american", 		cvar_team2_team, showDvar { "american" } ) \
	MATCHINFO_ICON(3 1, "hudicon_british", 			cvar_team2_team, showDvar { "british" } ) \
	MATCHINFO_ICON(3 1, "hudicon_russian", 			cvar_team2_team, showDvar { "russian" } ) \
	MATCHINFO_ICON(3 1, "hudicon_german", 			cvar_team2_team, showDvar { "german" } ) \
\
	ITEM_DVAR_DVAR("ui_matchinfo_team1_name", -115, 12, .2, ITEM_ALIGN_LEFT, 1 1 1 1, cvar_show, showDvar { "1" }) \
	ITEM_DVAR_DVAR("ui_matchinfo_team2_name", 16, 12, .2, ITEM_ALIGN_LEFT, 1 1 1 1, cvar_show, showDvar { "1" }) \
\
	ITEM_DVAR_DVAR("ui_matchinfo_round", 0, 24, .18, ITEM_ALIGN_CENTER, 1 1 1 1, cvar_show, showDvar { "1" }) \
\
	ITEM_DVAR_DVAR("ui_matchinfo_matchtime", -67, 24, .18, ITEM_ALIGN_CENTER, 1 1 1 1, cvar_show, showDvar { "1" }) \
	ITEM_DVAR_DVAR("ui_matchinfo_halfInfo", 67, 24, .18, ITEM_ALIGN_CENTER, 1 1 1 1, cvar_show, showDvar { "1" }) \
\
	ITEM_DVAR_DVAR("ui_matchinfo_map1", -195, 10, .18, ITEM_ALIGN_LEFT, 1 1 1 1, cvar_show, showDvar { "1" }) \
	ITEM_DVAR_DVAR("ui_matchinfo_map2", -195, 19, .18, ITEM_ALIGN_LEFT, 1 1 1 1, cvar_show, showDvar { "1" }) \
	ITEM_DVAR_DVAR("ui_matchinfo_map3", -195, 28, .18, ITEM_ALIGN_LEFT, 1 1 1 1, cvar_show, showDvar { "1" })







#define MATCHINFO_STREAMER_BGCOLOR(xywh, horizontal_align, bc, cvartest, showhidedvar) \
itemDef \
{ \
  style			WINDOW_STYLE_FILLED \
  rect			xywh horizontal_align 0 \
  backcolor		bc \
  visible		1 \
  dvartest		cvartest \
  showhidedvar \
  decoration \
}

#define MATCHINFO_STREAMER_IMAGE(xywh, horizontal_align, bg, color, cvartest, showhidedvar) \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		xywh horizontal_align 0 \
	backcolor	color \
	visible		1 \
	background	bg \
	dvartest	cvartest \
    showhidedvar \
	decoration \
}

#define MATCHINFO_STREAMER_TEXT(xy, horizontal_align, cvar, fontsize, txtalign, txtstyle, txtfont, fontcolor, dvartotest, dvarshowhide) \
itemDef \
{ \
	rect			xy 0 0 horizontal_align 0 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		fontcolor \
	textfont		txtfont \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		txtstyle \
	dvar			cvar \
	dvartest		dvartotest \
	dvarshowhide \
	decoration \
}

#define MATCHINFO_STREAMER(cvar_team1_team, cvar_team2_team, cvar_show, color_heading, color_allies, color_axis, color_allies2, color_axis2, color_text) \
\
	MATCHINFO_STREAMER_IMAGE(5 0 200 12, HORIZONTAL_ALIGN_LEFT, "streamer_mapbar", color_heading, "ui_streamersystem_mapHistory", hideDvar { "" } ) \
	MATCHINFO_STREAMER_TEXT(9 10,   HORIZONTAL_ALIGN_LEFT, "ui_streamersystem_mapHistory", 	.18, ITEM_ALIGN_LEFT, ITEM_TEXTSTYLE_NORMAL, UI_FONT_NORMAL, 1 1 1 1, cvar_show, showDvar { "1" }) \
\
	MATCHINFO_STREAMER_IMAGE(-188 0 375 11, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_topbar", color_heading, cvar_show, showDvar { "1" } ) \
\
	/* Background - Team 1*/ \
	MATCHINFO_STREAMER_IMAGE(-188 11 134 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team1", 				color_allies2, cvar_team1_team, showDvar { "american"; "british"; "russian"; } ) \
	MATCHINFO_STREAMER_IMAGE(-188 11 134 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team1", 				color_axis2,   cvar_team1_team, showDvar { "german" } ) \
	MATCHINFO_STREAMER_IMAGE(-188 11 134 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team1_gradient", 	color_allies, cvar_team1_team, showDvar { "american"; "british"; "russian"; } ) \
	MATCHINFO_STREAMER_IMAGE(-188 11 134 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team1_gradient", 	color_axis,   cvar_team1_team, showDvar { "german" } ) \
	/* Icon - Team 1 */ \
	MATCHINFO_STREAMER_IMAGE(-186 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_american", 	1 1 1 1, cvar_team1_team, showDvar { "american" } ) \
	MATCHINFO_STREAMER_IMAGE(-186 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_british", 	1 1 1 1, cvar_team1_team, showDvar { "british" } ) \
	MATCHINFO_STREAMER_IMAGE(-186 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_russian", 	1 1 1 1, cvar_team1_team, showDvar { "russian" } ) \
	MATCHINFO_STREAMER_IMAGE(-186 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_german", 	1 1 1 1, cvar_team1_team, showDvar { "german" } ) \
	/* Text - Team 1 name */ \
	MATCHINFO_STREAMER_TEXT(-119 24, HORIZONTAL_ALIGN_SUBLEFT, "ui_matchinfo_team1_name", 	.22, ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_NORMAL, color_text, cvar_show, showDvar { "1" }) \
\
	/* Background - Team 2*/ \
	MATCHINFO_STREAMER_IMAGE(54 11 133 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team2", 			color_allies2, cvar_team2_team, showDvar { "american"; "british"; "russian"; } ) \
	MATCHINFO_STREAMER_IMAGE(54 11 133 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team2", 			color_axis2,   cvar_team2_team, showDvar { "german" } ) \
	MATCHINFO_STREAMER_IMAGE(54 11 133 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team2_gradient", 	color_allies, cvar_team2_team, showDvar { "american"; "british"; "russian"; } ) \
	MATCHINFO_STREAMER_IMAGE(54 11 133 16, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_team2_gradient", 	color_axis,   cvar_team2_team, showDvar { "german" } ) \
	/* Icon - Team 2 */ \
	MATCHINFO_STREAMER_IMAGE(172 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_american", 	1 1 1 1, cvar_team2_team, showDvar { "american" } ) \
	MATCHINFO_STREAMER_IMAGE(172 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_british", 	1 1 1 1, cvar_team2_team, showDvar { "british" } ) \
	MATCHINFO_STREAMER_IMAGE(172 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_russian", 	1 1 1 1, cvar_team2_team, showDvar { "russian" } ) \
	MATCHINFO_STREAMER_IMAGE(172 12 14 14, HORIZONTAL_ALIGN_SUBLEFT, "hudicon_german", 		1 1 1 1, cvar_team2_team, showDvar { "german" } ) \
	/* Text - Team 2 name */ \
	MATCHINFO_STREAMER_TEXT(113 24,  HORIZONTAL_ALIGN_SUBLEFT, "ui_matchinfo_team2_name", 	.22, ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_NORMAL, color_text, cvar_show, showDvar { "1" }) \
\
	\
	/* Match bar */ \
	MATCHINFO_STREAMER_IMAGE(-55 11 109 22, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_middlebar", 		color_heading, cvar_show, showDvar { "1" } ) \
	/* Text - Team 1 score */ \
	MATCHINFO_STREAMER_IMAGE(-55 11 25 22, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_score", 		1 1 1 0.1, cvar_show, showDvar { "1" } ) \
	MATCHINFO_STREAMER_TEXT(-42 28,  HORIZONTAL_ALIGN_SUBLEFT, "ui_matchinfo_team1_score", 	.3, ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_BOLD, 1 1 1 1, cvar_show, showDvar { "1" }) \
	/* Text - Team 2 score */ \
	MATCHINFO_STREAMER_IMAGE(29 11 25 22, HORIZONTAL_ALIGN_SUBLEFT, "streamer_matchinfo_score", 		1 1 1 0.1, cvar_show, showDvar { "1" } ) \
	MATCHINFO_STREAMER_TEXT(41 28,  HORIZONTAL_ALIGN_SUBLEFT, "ui_matchinfo_team2_score", 	.3, ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_BOLD, 1 1 1 1, cvar_show, showDvar { "1" }) \
\
	MATCHINFO_STREAMER_TEXT(0 10,    HORIZONTAL_ALIGN_CENTER, "ui_streamersystem_heading", 	        .15, ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_NORMAL, 1 1 1 1, cvar_show, showDvar { "1" }) \
	MATCHINFO_STREAMER_TEXT(0 21,    HORIZONTAL_ALIGN_CENTER, "ui_matchinfo_round", 	            .15, ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_NORMAL, 1 1 1 1, cvar_show, showDvar { "1" }) \
	MATCHINFO_STREAMER_TEXT(0 30,   HORIZONTAL_ALIGN_CENTER, "ui_matchinfo_state", 	                .19,  ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_NORMAL, 1 1 1 1, cvar_show, showDvar { "1" }) \
	MATCHINFO_STREAMER_TEXT(0 42,   HORIZONTAL_ALIGN_CENTER, "ui_streamersystem_scoreProgress", 	.2,  ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_SHADOWED, UI_FONT_NORMAL, 1 1 1 1, cvar_show, showDvar { "1" }) \
\
	/* 5v5  5v4  5v3  4v3 */ \
	/*MATCHINFO_STREAMER_BGCOLOR(-258 449 40 18, HORIZONTAL_ALIGN_RIGHT, color_heading, 	"ui_streamersystem_playerProgress", hideDvar { "" })*/ \
	/*MATCHINFO_STREAMER_TEXT(-239 463,           HORIZONTAL_ALIGN_RIGHT, "ui_streamersystem_playerProgress", 	.3, ITEM_ALIGN_CENTER, ITEM_TEXTSTYLE_NORMAL, UI_FONT_NORMAL, 1 1 1 1, cvar_show, showDvar { "1" })*/ \
\





#define STREAMERSYSTEM_COLOR_HIGHLIGHT .9 .9 .9 1
#define STREAMERSYSTEM_COLOR_BG .5 .5 .5 .9
#define STREAMERSYSTEM_COLOR_BG_DEAD .0 .0 .0 .4

#define ITEM_STREAMERSYSTEM_LINE(cvarprefix, num, img_num, x_offset, y_offset, horizontal_align, color_allies, color_axis, color_allies_BG, color_axis_BG, color_allies_damage, color_axis_damage, color_text, color_text2) \
/* Highlight*/ \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 130 25 horizontal_align 0 \
	origin		-1 -1 \
	visible		1 \
	backcolor	STREAMERSYSTEM_COLOR_HIGHLIGHT \
	background	"streamer_playerbar_bg" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_allies_";"10_axis_";  "50_allies_";"50_axis_";  "80_allies_"; "80_axis_";  "100_allies_";"100_axis_" } \
	decoration \
} \
\
\
\
\
/* Background - Allies color when alive */ \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_allies_BG \
	background	"streamer_playerbar_bg" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_allies_";"10_allies";  "50_allies_";"50_allies";  "80_allies_";"80_allies";  "100_allies_";"100_allies" } \
	decoration \
} \
/* Background - Axis color when alive */ \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_axis_BG \
	background	"streamer_playerbar_bg" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_axis_";"10_axis";  "50_axis_";"50_axis";  "80_axis_";"80_axis";  "100_axis_";"100_axis" } \
	decoration \
} \
\
/* Gradient */ \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_allies \
	background	"streamer_playerbar_gradient" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_allies_";"10_allies";  "50_allies_";"50_allies";  "80_allies_";"80_allies";  "100_allies_";"100_allies" } \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_axis \
	background	"streamer_playerbar_gradient" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_axis_";"10_axis";  "50_axis_";"50_axis";  "80_axis_";"80_axis";  "100_axis_";"100_axis" } \
	decoration \
} \
\
\
\
/* Background - Health */ \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_allies_damage \
	background	"streamer_playerbar_damage_20" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "80_allies"; "80_allies_" } \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_axis_damage \
	background	"streamer_playerbar_damage_20" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "80_axis"; "80_axis_" } \
	decoration \
} \
\
\
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_allies_damage \
	background	"streamer_playerbar_damage_50" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "50_allies"; "50_allies_" } \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_axis_damage \
	background	"streamer_playerbar_damage_50" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "50_axis"; "50_axis_" } \
	decoration \
} \
\
\
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_allies_damage \
	background	"streamer_playerbar_damage_90" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_allies"; "10_allies_" } \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	color_axis_damage \
	background	"streamer_playerbar_damage_90" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_axis"; "10_axis_" } \
	decoration \
} \
\
\
\
/* Player number circle */ \
itemDef \
{ \
	/* Background - Allies stripe when alive */ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 9 9 horizontal_align 0 \
	origin		123 2 \
	backcolor	color_allies_BG \
	visible		1 \
	background  "streamer_playerbar_circle" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_allies_";"10_allies";  "50_allies_";"50_allies";  "80_allies_";"80_allies";  "100_allies_";"100_allies" } \
	decoration \
} \
itemDef \
{ \
	/* Background - Axis stripe when alive */ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 9 9 horizontal_align 0 \
	origin		123 2 \
	backcolor	color_axis_BG \
	background  "streamer_playerbar_circle" \
	visible		1 \
	dvartest	cvarprefix "_health" \
	showDvar	{ "10_axis_";"10_axis";  "50_axis_";"50_axis";  "80_axis_";"80_axis";  "100_axis_";"100_axis" } \
	decoration \
} \
itemDef \
{ \
	/* Text - number of player (visible when alive) */ \
	rect			x_offset y_offset 0 0 horizontal_align 0 \
	origin			127 -1 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		color_text \
	textfont		UI_FONT_NORMAL \
	textscale		.15 \
	textalign		ITEM_ALIGN_CENTER \
	textaligny		11 \
	textstyle		ITEM_TEXTSTYLE_NORMAL \
	text			num \
	dvartest		cvarprefix "_health" \
	hideDvar		{ ""; "0"; "0_" } \
	decoration \
} \
\
\
\
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 10 9 horizontal_align 0 \
	backcolor	1 1 1 .5 \
	origin		116 12 \
	visible		1 \
	background	"gfx/icons/hud@us_grenade.tga" \
	dvartest	cvarprefix "_icons" \
	showDvar	{ "grenade"; "grenade_smoke"; "grenade2_smoke"; "grenade2"; } \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 10 9 horizontal_align 0 \
	backcolor	1 1 1 .5 \
	origin		113 12 \
	visible		1 \
	background	"gfx/icons/hud@us_grenade.tga" \
	dvartest	cvarprefix "_icons" \
	showDvar	{ "grenade2"; "grenade2_smoke"; } \
	decoration \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 10 9 horizontal_align 0 \
	backcolor	1 1 1 .5 \
	origin		107 12 \
	visible		1 \
	background	"hud_us_smokegrenade" \
	dvartest	cvarprefix "_icons" \
	showDvar	{ "smoke"; "grenade_smoke"; "grenade2_smoke";  } \
	decoration \
} \
\
itemDef \
{ \
	rect			x_offset y_offset 0 0 horizontal_align 0 \
	origin			5 0 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		color_text \
	textfont		UI_FONT_NORMAL \
	textscale		.18 \
	textalign		ITEM_ALIGN_LEFT \
	textaligny		11 \
	textstyle		ITEM_TEXTSTYLE_NORMAL \
	dvar			cvarprefix "_name" \
	dvartest		cvarprefix "_health" \
	hideDvar		{ ""; } \
	decoration \
} \
itemDef \
{ \
	rect			x_offset y_offset 0 0 horizontal_align 0 \
	origin			5 9 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		color_text2 \
	textfont		UI_FONT_NORMAL \
	textscale		.16 \
	textalign		ITEM_ALIGN_LEFT \
	textaligny		12 \
	textstyle		ITEM_TEXTSTYLE_NORMAL \
	dvar			cvarprefix "_score" \
	dvartest		cvarprefix "_health" \
	hideDvar		{ "" } \
	decoration \
} \
itemDef \
{ \
	rect			x_offset y_offset 0 0 horizontal_align 0 \
	origin			29 9 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		color_text2 \
	textfont		UI_FONT_NORMAL \
	textscale		.15 \
	textalign		ITEM_ALIGN_LEFT \
	textaligny		12 \
	textstyle		ITEM_TEXTSTYLE_NORMAL \
	dvar			cvarprefix "_weapon" \
	dvartest		cvarprefix "_health" \
	hideDvar		{ "" } \
	decoration \
} \
itemDef \
{ \
	rect			x_offset y_offset 0 0 horizontal_align 0 \
	origin			96 9 \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		1 1 1 1 \
	textfont		UI_FONT_NORMAL \
	textscale		.18 \
	textalign		ITEM_ALIGN_LEFT \
	textaligny		12 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvar			cvarprefix "_round_kills" \
	dvartest		cvarprefix "_health" \
	hideDvar		{ "" } \
	decoration \
} \
\
/* If dead, overlay whole bar to dim the texts*/ \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 128 23 horizontal_align 0 \
	visible		1 \
	backcolor	STREAMERSYSTEM_COLOR_BG_DEAD \
	background	"streamer_playerbar_bg" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "0"; "0_" } \
	decoration \
} \
\
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x_offset y_offset 15 15 horizontal_align 0 \
	backcolor	1 1 1 .5 \
	origin		112 4 \
	visible		1 \
	background	"gfx/hud/death_suicide.tga" \
	dvartest	cvarprefix "_health" \
	showDvar	{ "0"; "0_";  } \
	decoration \
} \






#define ITEM_STREAMERSYSTEM_KEY(textstring, x, y, fontSize, horizontal_align, cvar) \
itemDef \
{ \
	visible			1 \
	rect			0 0 1 1 horizontal_align 0 \
	origin			x y \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_TEXT \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		fontSize \
	dvartest		cvar \
	showDvar		{ "1"; } \
	decoration \
}


#define ITEM_STREAMERSYSTEM_DVAR(x, y, fontsize, cvar, horizontal_align, text_align) \
itemDef \
{ \
	visible			1 \
	rect			0 0 0 0 horizontal_align 0 \
	origin			x y \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	type			ITEM_TYPE_TEXT \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		text_align \
	dvar			cvar \
	decoration \
}

#define ITEM_STREAMERSYSTEM_BG(rect2, bgcolor, cvar, showhide) \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	visible			1 \
	rect			rect2 \
	backcolor		bgcolor \
	dvartest		cvar \
	showhide \
	decoration \
}







#define SCOREBOARD_TEXT_ALIGNY 10
#define SCOREBOARD_HEADING_ALIGNY 25

// Text headings of columns
#define SCOREBOARD_SCORE_TEXT_X 174
#define SCOREBOARD_KILLS_TEXT_X 210
#define SCOREBOARD_DEATHS_TEXT_X 228
#define SCOREBOARD_ASSISTS_TEXT_X 264
#define SCOREBOARD_DAMAGE_TEXT_X 294
#define SCOREBOARD_GRENADES_TEXT_X 324
#define SCOREBOARD_PLANTS_TEXT_X 354
#define SCOREBOARD_DEFUSES_TEXT_X 388
#define SCOREBOARD_DEFUSES_TEXT_X_LINE 384	// last one is aligned right

// Columns
#define SCOREBOARD_HEADING_X 15
#define SCOREBOARD_NAME_X 33

#define SCOREBOARD_SCORE_X 167
#define SCOREBOARD_KILLS_X 208
#define SCOREBOARD_DEATHS_X 226
#define SCOREBOARD_ASSISTS_X 262
#define SCOREBOARD_DAMAGE_X 288
#define SCOREBOARD_GRENADES_X 322
#define SCOREBOARD_PLANTS_X 352
#define SCOREBOARD_DEFUSES_X 382
#define SCOREBOARD_PING_X 420



#define SCOREBOARD_LINE_1_Y  30
#define SCOREBOARD_LINE_2_Y  40
#define SCOREBOARD_LINE_3_Y  50
#define SCOREBOARD_LINE_4_Y  59
#define SCOREBOARD_LINE_5_Y  69
#define SCOREBOARD_LINE_6_Y  79
#define SCOREBOARD_LINE_7_Y  88
#define SCOREBOARD_LINE_8_Y  98
#define SCOREBOARD_LINE_9_Y  108
#define SCOREBOARD_LINE_10_Y 117
#define SCOREBOARD_LINE_11_Y 127
#define SCOREBOARD_LINE_12_Y 137
#define SCOREBOARD_LINE_13_Y 146
#define SCOREBOARD_LINE_14_Y 156
#define SCOREBOARD_LINE_15_Y 166
#define SCOREBOARD_LINE_16_Y 175
#define SCOREBOARD_LINE_17_Y 185
#define SCOREBOARD_LINE_18_Y 195
#define SCOREBOARD_LINE_19_Y 204
#define SCOREBOARD_LINE_20_Y 214
#define SCOREBOARD_LINE_21_Y 224
#define SCOREBOARD_LINE_22_Y 233
#define SCOREBOARD_LINE_23_Y 243
#define SCOREBOARD_LINE_24_Y 253
#define SCOREBOARD_LINE_25_Y 263
#define SCOREBOARD_LINE_26_Y 273

#define SCOREBOARD_LINE_BACKGROUND_COLOR 		.0 .0 .0 .1
#define SCOREBOARD_LINE_BACKGROUND_COLOR_HIGHLIGHTED 	.2 .2 .2 .7
#define SCOREBOARD_LINE_BACKGROUND_COLOR_DISCONNECTED	.2 .0 .0 .2
/*
type
0 = hide
1 = player line - odd
2 = player line - even
3 = player line - highlighted
"<string>" = show team name

added _ means that line can be clicked
added ! means that player is disconnected
*/
#define ITEM_SCOREBOARD_LINE(line_id, x, y, y_offset) \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			10 y_offset 380 10 0 0 \
	origin			x y \
	backcolor		SCOREBOARD_LINE_BACKGROUND_COLOR \
	visible			1 \
	dvartest		"ui_scoreboard_line_" line_id \
	showDvar		{ "2";"2_"; } \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			10 y_offset 380 10 0 0 \
	origin			x y \
	backcolor		SCOREBOARD_LINE_BACKGROUND_COLOR_HIGHLIGHTED \
	visible			1 \
	dvartest		"ui_scoreboard_line_" line_id \
	showDvar		{ "3";"3_"; } \
	decoration \
} \
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			10 y_offset 380 10 0 0 \
	origin			x y \
	backcolor		SCOREBOARD_LINE_BACKGROUND_COLOR_DISCONNECTED \
	visible			1 \
	dvartest		"ui_scoreboard_line_" line_id \
	showDvar		{ "1!";"2!";"3!" } \
	decoration \
} \
itemDef \
{ \
	rect			SCOREBOARD_HEADING_X y_offset 1 1 0 0 \
	origin			x y \
	dvar 			"ui_scoreboard_line_" line_id \
	textfont		UI_FONT_BIG \
	textscale		0.32 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		SCOREBOARD_HEADING_ALIGNY \
	visible			1 \
	dvartest		"ui_scoreboard_line_" line_id \
	hideDvar		{ ""; "0"; "1"; "2"; "3";  "0_"; "1_"; "2_"; "3_";  "0!"; "1!"; "2!"; "3!"; } \
	decoration \
} \
\
itemDef  \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			10 y_offset 16 10 0 0 \
        origin			x y \
	backcolor		0 0 0 0.7 \
	visible			1 \
	dvartest		"ui_scoreboard_line_" line_id \
        showDvar		{ "0_"; "1_"; "2_"; "3_"; } \
	decoration \
}  \
itemDef \
{ \
	rect			0 y_offset 390 10 0 0 \
        origin			x y \
	type			ITEM_TYPE_BUTTON \
	visible			1 \
	forecolor		1 1 1 1 \
	text			"Set" \
	textfont		UI_FONT_NORMAL \
	textscale		0.18 \
	textalign		ITEM_ALIGN_LEFT \
	textalignx		13 \
	textaligny		8 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvartest		"ui_scoreboard_line_" line_id \
        showDvar		{ "0_"; "1_"; "2_"; "3_"; } \
	action \
	{ \
		play "mouse_click"; \
		exec "openscriptmenu ingame scoreboard_setPlayer" line_id \
	} \
	onFocus \
	{ \
		play "mouse_over"; \
	} \
}

#define ITEM_SCOREBOARD_HEADING(x, y, textstring, x_offset, y_offset, fontsize, txtalign, line_x, line_y, line_height) \
itemDef \
{ \
	rect			x_offset y_offset 1 1 0 0 \
	origin			x y \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		1 1 1 1 \
	text			textstring \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvartest		"ui_scoreboard_visible" \
	showDvar		{ "1"; } \
	decoration \
}  \
itemDef \
{ \
	style			WINDOW_STYLE_FILLED \
	rect			line_x line_y 0.75 line_height 0 0 \
        origin			x y \
	backcolor		1 1 1 .1 \
	visible			1 \
	dvartest		"ui_scoreboard_visible" \
	showDvar		{ "1"; } \
	decoration \
}


#define ITEM_SCOREBOARD_COLUMN(x, y, cvar, x_offset, y_offset, fontsize, txtalign) \
itemDef \
{ \
	rect			x_offset y_offset 200 50 0 0 \
	origin			x y \
	type			ITEM_TYPE_TEXT \
	visible			1 \
	forecolor		1 1 1 1 \
	textfont		UI_FONT_NORMAL \
	textscale		fontsize \
	textalign		txtalign \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	dvar			cvar \
	decoration \
}


#define ITEM_SCOREBOARD(x, y) \
\
	ITEM_SCOREBOARD_HEADING(x, y, "Score",    SCOREBOARD_SCORE_TEXT_X,   	23, .21, ITEM_ALIGN_CENTER, 	SCOREBOARD_SCORE_TEXT_X, 	25, 	30) \
	ITEM_SCOREBOARD_HEADING(x, y, "Kills",    SCOREBOARD_KILLS_TEXT_X,   	23, .21, ITEM_ALIGN_CENTER, 	SCOREBOARD_KILLS_TEXT_X, 	25, 	30) \
	ITEM_SCOREBOARD_HEADING(x, y, "Deaths",   SCOREBOARD_DEATHS_TEXT_X,  	33, .21, ITEM_ALIGN_CENTER, 	SCOREBOARD_DEATHS_TEXT_X, 	35, 	20) \
	ITEM_SCOREBOARD_HEADING(x, y, "Assists",  SCOREBOARD_ASSISTS_TEXT_X, 	23, .21, ITEM_ALIGN_CENTER, 	SCOREBOARD_ASSISTS_TEXT_X, 	25, 	30) \
	ITEM_SCOREBOARD_HEADING(x, y, "Hits",     SCOREBOARD_DAMAGE_TEXT_X,  	33, .21, ITEM_ALIGN_CENTER, 	SCOREBOARD_DAMAGE_TEXT_X, 	35, 	20) \
	ITEM_SCOREBOARD_HEADING(x, y, "Grenades", SCOREBOARD_GRENADES_TEXT_X,	23, .21, ITEM_ALIGN_CENTER, 	SCOREBOARD_GRENADES_TEXT_X, 	25, 	30) \
	ITEM_SCOREBOARD_HEADING(x, y, "Plants",   SCOREBOARD_PLANTS_TEXT_X,  	33, .21, ITEM_ALIGN_CENTER, 	SCOREBOARD_PLANTS_TEXT_X, 	35, 	20) \
	ITEM_SCOREBOARD_HEADING(x, y, "Defuses",  SCOREBOARD_DEFUSES_TEXT_X, 	23, .21, ITEM_ALIGN_RIGHT,  	SCOREBOARD_DEFUSES_TEXT_X_LINE, 25, 	30) \
\
	ITEM_SCOREBOARD_LINE("1", x, y, SCOREBOARD_LINE_1_Y) \
\
	ITEM_SCOREBOARD_LINE("4", x, y, SCOREBOARD_LINE_4_Y) \
	ITEM_SCOREBOARD_LINE("5", x, y, SCOREBOARD_LINE_5_Y) \
	ITEM_SCOREBOARD_LINE("6", x, y, SCOREBOARD_LINE_6_Y) \
	ITEM_SCOREBOARD_LINE("7", x, y, SCOREBOARD_LINE_7_Y) \
	ITEM_SCOREBOARD_LINE("8", x, y, SCOREBOARD_LINE_8_Y) \
	ITEM_SCOREBOARD_LINE("9", x, y, SCOREBOARD_LINE_9_Y) \
	ITEM_SCOREBOARD_LINE("10", x, y, SCOREBOARD_LINE_10_Y) \
	ITEM_SCOREBOARD_LINE("11", x, y, SCOREBOARD_LINE_11_Y) \
	ITEM_SCOREBOARD_LINE("12", x, y, SCOREBOARD_LINE_12_Y) \
	ITEM_SCOREBOARD_LINE("13", x, y, SCOREBOARD_LINE_13_Y) \
	ITEM_SCOREBOARD_LINE("14", x, y, SCOREBOARD_LINE_14_Y) \
	ITEM_SCOREBOARD_LINE("15", x, y, SCOREBOARD_LINE_15_Y) \
	ITEM_SCOREBOARD_LINE("16", x, y, SCOREBOARD_LINE_16_Y) \
	ITEM_SCOREBOARD_LINE("17", x, y, SCOREBOARD_LINE_17_Y) \
	ITEM_SCOREBOARD_LINE("18", x, y, SCOREBOARD_LINE_18_Y) \
	ITEM_SCOREBOARD_LINE("19", x, y, SCOREBOARD_LINE_19_Y) \
	ITEM_SCOREBOARD_LINE("20", x, y, SCOREBOARD_LINE_20_Y) \
	ITEM_SCOREBOARD_LINE("21", x, y, SCOREBOARD_LINE_21_Y) \
	ITEM_SCOREBOARD_LINE("22", x, y, SCOREBOARD_LINE_22_Y) \
	ITEM_SCOREBOARD_LINE("23", x, y, SCOREBOARD_LINE_23_Y) \
	ITEM_SCOREBOARD_LINE("24", x, y, SCOREBOARD_LINE_24_Y) \
	ITEM_SCOREBOARD_LINE("25", x, y, SCOREBOARD_LINE_25_Y) \
	ITEM_SCOREBOARD_LINE("26", x, y, SCOREBOARD_LINE_26_Y) \
\
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_names",    SCOREBOARD_NAME_X,     40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_scores",   SCOREBOARD_SCORE_X,    40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_kills",    SCOREBOARD_KILLS_X,    40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_deaths",   SCOREBOARD_DEATHS_X,   40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_assists",  SCOREBOARD_ASSISTS_X,  40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_damages",  SCOREBOARD_DAMAGE_X,   40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_grenades", SCOREBOARD_GRENADES_X, 40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_plants",   SCOREBOARD_PLANTS_X,   40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_defuses",  SCOREBOARD_DEFUSES_X,  40, .2, ITEM_ALIGN_LEFT) \
	ITEM_SCOREBOARD_COLUMN(x, y, "ui_scoreboard_ping",     SCOREBOARD_PING_X,     40, .2, ITEM_ALIGN_LEFT)




#define ITEM_SLIDER(x, y, cvarname, minval, maxval) \
itemDef \
{ \
	/*name 		slidebar_desc*/ \
	rect 		x y 65 12 0 0 \
	origin 		0 0 \
	type 		ITEM_TYPE_BUTTON \
	text 		cvarname \
	textstyle	OPTIONS_ITEM_TEXT_STYLE \
	textalignx	0 \
	textaligny	13 \
	textscale	.25 \
	style		WINDOW_STYLE_FILLED \
	backcolor	OPTIONS_CONTROL_BACKCOLOR \
	forecolor	OPTIONS_CONTROL_FORECOLOR \
	visible 1 \
	decoration \
} \
itemDef \
{ \
	/*name 		slidebar_bar*/ \
	rect		x y 320 13 0 0 \
	origin 		40 0 \
	type 		ITEM_TYPE_SLIDER \
	text 		" " \
	dvarfloat 	cvarname 0 minval maxval \
	style		WINDOW_STYLE_FILLED \
	textalignx	0 \
	textaligny	11 \
	visible		1 \
} \
itemDef \
{ \
	/*name 		slidebar_value \*/ \
	rect 		x y 65 12 0 0 \
	origin 		130 0 \
	type 		ITEM_TYPE_DECIMALFIELD \
	text 		"" \
	dvarfloat 	cvarname 0 minval maxval \
	textstyle	OPTIONS_ITEM_TEXT_STYLE \
	textalignx	0 \
	textaligny	11 \
	textscale	.25 \
	style		WINDOW_STYLE_FILLED \
	backcolor	OPTIONS_CONTROL_BACKCOLOR \
	forecolor	OPTIONS_CONTROL_FORECOLOR \
	visible 1 \
	decoration \
}

// All sub-menus that can be possibly opened at the same time
#define CLOSE_SUBMENUS close ingame_keys; close team_britishgerman_keys; close team_americangerman_keys; close team_russiangerman_keys; close ingame_scoreboard_sd; close rcon_map; close rcon_map_maps; close rcon_map_pams; close rcon_map_other; close rcon_map_apply; close rcon_settings; close rcon_settings_shared; close rcon_settings_gametypes; close rcon_settings_focus; close rcon_kick; close aboutpam; close pammodes;
#define CLOSE_ALL CLOSE_SUBMENUS close ingame; close team_britishgerman; close team_americangerman; close team_russiangerman;
