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

#define ITEM_WEAPON_SMOKE(originpos, stringname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, class_usedby) \
ITEM_WEAPON(originpos, stringname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, class_usedby) \
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

#define ITEM_WEAPON(originpos, stringname, stringtext, cvartext, weaponimage, focusaction, doaction, grenadeimage, class_usedby) \
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
	dvartest		"ui_weapons_" class_usedby "_usedby" \
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
	dvar			"ui_weapons_" class_usedby "_usedby"  \
	dvartest		"ui_weapons_" class_usedby "_usedby" \
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
	textscale		0.3 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textaligny		16 \
	decoration \
}

#define SERVERINFO_DRAW_PARAMETERS \
itemDef \
{ \
	visible			1 \
	rect			0 0 180 110 0 0 \
	origin			170 180 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_left1" \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
	textstyle		ITEM_TEXTSTYLE_SHADOWED \
	textalign		ITEM_ALIGN_RIGHT \
	autowrapped \
	decoration \
} \
itemDef  \
{ \
	visible			1 \
	rect			0 0 128 110 0 0 \
	origin			185 180 \
	forecolor		GLOBAL_UNFOCUSED_COLOR \
	dvar			"ui_serverinfo_left2" \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
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
	textscale		0.3 \
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
	textscale		0.3 \
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
	autowrapped \
	dvar			"ui_motd" \
	textfont		UI_FONT_NORMAL \
	textscale		0.3 \
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


// All sub-menus that can be possibly opened at the same time
#define CLOSE_SUBMENUS close ingame_keys; close team_britishgerman_keys; close team_americangerman_keys; close team_russiangerman_keys; close ingame_scoreboard_sd; close rcon_map; close rcon_map_maps; close rcon_map_pams; close rcon_map_other; close rcon_map_apply; close rcon_settings; close rcon_settings_shared; close rcon_settings_gametypes; close rcon_settings_focus; close rcon_kick; close aboutpam; close pammodes;
#define CLOSE_ALL CLOSE_SUBMENUS close ingame; close team_britishgerman; close team_americangerman; close team_russiangerman;
