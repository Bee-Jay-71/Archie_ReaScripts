--[[
   * Тест только на windows  /  Test only on windows.
   * Отчет об ошибке: Если обнаружите какие либо ошибки, то сообщите по одной из указанных ссылок ниже (*Website)
   * Bug Reports: If you find any errors, please report one of the links below (*Website)
   *
   * Category:    Item
   * Features:    Startup
   * Description: Item;  Grab item on edge arrange and trim by edge window(AutoRun).lua
   * Author:      Archie
   * Version:     1.02
   * AboutScript: ---
   * О скрипте:   Захватите элемент на краю аранжировке и обрезайте по краю окна
   * GIF:         http://avatars.mds.yandex.net/get-pdb/2883421/8cf1c573-4267-4458-acf8-21b0050c7edb/orig
   *              http://avatars.mds.yandex.net/get-pdb/2423768/3d18d682-49c3-4a64-a4cd-4df56377c0db/orig
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   *              http://vk.com/reaarchie
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * Customer:    YuriOl(Rmm)
   * Gave idea:   YuriOl(Rmm)
   * Extension:   Reaper 6.10+ http://www.reaper.fm/
   *              SWS v.2.12.0 http://www.sws-extension.org/index.php
   *              reaper_js_ReaScriptAPI64 Repository - (ReaTeam Extensions) http://clck.ru/Eo5Nr or http://clck.ru/Eo5Lw
   *              Arc_Function_lua v.2.8.0+ (Repository: Archie-ReaScripts) http://clck.ru/EjERc
   * Changelog:   
   *              v.1.02 [240520]
   *                  + No changeе
   
   *              v.1.0 [230520]
   *                  + initialе
--]] 
    --======================================================================================
    --////////////  НАСТРОЙКИ  \\\\\\\\\\\\  SETTINGS  ////////////  НАСТРОЙКИ  \\\\\\\\\\\\
    --======================================================================================
    
    
    local PixelsToCapture = 5 -- Пикселей скраю для захвата (5)
    local offset = 2 -- pixel отступ (2)
    local ScrollBar = 19 -- pixel Полоса прокрутки справа (19)
    
    
    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================
    
    
    local STARTUP = 1; -- (Not recommended change)
    --==== FUNCTION MODULE FUNCTION ======================= FUNCTION MODULE FUNCTION ============== FUNCTION MODULE FUNCTION ==================
    local P,F,L,A=reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions','/Arc_Function_lua.lua';L,A=pcall(dofile,P..F);if not L then
    reaper.RecursiveCreateDirectory(P,0);reaper.ShowConsoleMsg("Error - "..debug.getinfo(1,'S').source:match('.*[/\\](.+)')..'\nMissing file'..
    '/ Отсутствует файл!\n'..P..F..'\n\n')return;end;if not A.VersionArc_Function_lua("2.8.0",P,"")then A.no_undo() return end;local Arc=A;--==
    --==== FUNCTION MODULE FUNCTION ===================================================▲=▲=▲======= FUNCTION MODULE FUNCTION ==================
    
    
    local section = 'Archie_GRAB_ITEM_ON_EDGE_ARRANGE';
    local scriptPath,scriptName = debug.getinfo(1,'S').source:match("^@(.+)[/\\](.+)");
    local extname = scriptName;
    
    
    ----------------------------------------------------------------
    local function main();
    
        Arc.HelpWindowWhenReRunning(2,'',false,' - '..extname);
        
        --- / Счетчик для пропуска / ---
        local function Counter();
            local t={};return function(x,b)b=b or 1 t[b]=(t[b]or 0)+1 if t[b]>(x or math.huge)then t[b]=0 end return t[b]end;  
        end;Counter = Counter(); -- Counter(x,buf); x=reset
        
        local itemX,_;
        
        local function loop();
            if Counter(2,1) == 0 then;
                ------------------
                local ExtState = reaper.GetExtState(section,'TGL_SWITCH');
                local ExtStTGL = tonumber(reaper.GetExtState(section,'TOGGLE_TRIM'))or 0;
                if ExtState ~= 'TRIM' or ExtStTGL == 0 then;
                    reaper.SetExtState(section,'TOGGLE_TRIM',0,true);
                    Arc.GetSetToggleButtonOnOff(0,1);
                    return;
                end;
                ------------------
                local MouseState = reaper.JS_Mouse_GetState(127);
                local ScrollBarL = ScrollBar/reaper.GetHZoomLevel();
                local offsetL = offset/reaper.GetHZoomLevel();
                local edge = PixelsToCapture/reaper.GetHZoomLevel();--Пиксели в секунды
                local start_time,end_time = reaper.GetSet_ArrangeView2(0,0,0,0);
                local PosMCur = reaper.BR_PositionAtMouseCursor(false);
                local ms_x,ms_y = reaper.GetMousePosition();
                ----
                if MouseState == 0 then;
                    itemX,_ = reaper.GetItemFromPoint(ms_x,ms_y,false);
                    if itemX then;
                        local pos = reaper.GetMediaItemInfo_Value(itemX,'D_POSITION');
                        local len = reaper.GetMediaItemInfo_Value(itemX,'D_LENGTH');
                        local endPos = pos+len;
                        ----
                        if PosMCur <= start_time+edge and pos < start_time then;
                            reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(32649));
                        elseif PosMCur>=(end_time-ScrollBarL-edge)and endPos > end_time then;
                            reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(32649));
                        end;
                    end;
                end;
                ----
                if MouseState == 1 then;
                    local item,take = reaper.GetItemFromPoint(ms_x,ms_y,false);
                    if item and item == itemX then;
                        local pos = reaper.GetMediaItemInfo_Value(item,'D_POSITION');
                        local len = reaper.GetMediaItemInfo_Value(item,'D_LENGTH');
                        local endPos = pos+len;
                        ----
                        if PosMCur <= start_time+edge then;
                            ----
                            if (pos < start_time) and (endPos > (start_time+edge)) then;
                                reaper.Undo_BeginBlock();
                                local posNew = start_time + offsetL;
                                Arc.SetMediaItemLeftTrim2(posNew,item);
                                reaper.Undo_EndBlock('Trim Left',-1);
                                reaper.UpdateTimeline();
                                itemX = nil;
                            end;
                            ----
                        elseif PosMCur>=(end_time-ScrollBarL-edge)then;
                            ----
                            reaper.Undo_BeginBlock();
                            local lenNew = (end_time - pos)-ScrollBarL-offsetL;
                            reaper.SetMediaItemLength(item,lenNew,true);
                            reaper.Undo_EndBlock('Trim Right',-1);
                            reaper.UpdateTimeline();
                            itemX = nil;
                            ----
                        end;
                        itemX = nil;
                    end;
                end;
            end;
            ------------------
            reaper.defer(loop);
        end;
        reaper.defer(loop);
    end;--End main
    ----------------------------------------------------------------
    
    
    
    ----------------------------------------------------------------
    local function run();
        local ExtStTGL = tonumber(reaper.GetExtState(section,'TOGGLE_TRIM'))or 0;
        if ExtStTGL == 0 then;
            reaper.SetExtState(section,'TGL_SWITCH','TRIM',true);
            reaper.SetExtState(section,'TOGGLE_TRIM',1,true);
            Arc.GetSetToggleButtonOnOff(1,1);
            reaper.defer(main);
        else;
            Arc.GetSetToggleButtonOnOff(0,1);
            reaper.SetExtState(section,'TOGGLE_TRIM',0,true);
        end;
    end;
    
    
    local function runFirst();
        local ExtState = reaper.GetExtState(section,'TGL_SWITCH');
        local ExtStTGL = tonumber(reaper.GetExtState(section,'TOGGLE_TRIM'))or 0;
        if ExtState == 'TRIM' and ExtStTGL == 1 then;
            Arc.GetSetToggleButtonOnOff(1,1);
            reaper.defer(main);
        end;
    end;
    ----------------------------------------------------------------
    
    
     
    ---___-----------------------------------------------
    local FirstRun;
    if STARTUP == 1 then;
        --reaper.DeleteExtState(extname,"FirstRun",false);
        FirstRun = reaper.GetExtState(extname,"FirstRun")=="";
        if FirstRun then;
            reaper.SetExtState(extname,"FirstRun",1,false);
        end;
    end;
    -----------------------------------------------------
    
    
    ---------------------
    if not FirstRun then;
        run();
    elseif FirstRun then;
        runFirst();
    end;
    ---------------------
    
    
    ---___-----------------------------------------------
    local function SetStartupScriptWrite();
        local id = Arc.GetIDByScriptName(scriptName,scriptPath);
        if id == -1 or type(id) ~= "string" then Arc.no_undo()return end;
        local check_Id, check_Fun = Arc.GetStartupScript(id);
        if STARTUP == 1 then;
            if not check_Id then;
                Arc.SetStartupScript(scriptName,id);
            end;
        elseif STARTUP ~= 1 then;
            if check_Id then;
                Arc.SetStartupScript(scriptName,id,nil,"ONE");
            end;
        end;
    end;
    reaper.defer(SetStartupScriptWrite);
    -----------------------------------------------------
    
    
    
    
    
    