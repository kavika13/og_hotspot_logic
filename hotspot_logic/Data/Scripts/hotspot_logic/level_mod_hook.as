void Init(string level_name) {
}

void Update(int is_paused) {
    // For debugging
    // if(GetInputPressed(0, "o")) {
    //     for(int i = 0; i < GetNumHotspots(); i++) {
    //         Hotspot@ hotspot = ReadHotspot(i);

    //         if(hotspot.GetTypeString() == "hotspot_logic") {
    //             Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
    //             hotspot_obj.ReceiveScriptMessage("hotspot_logic_log_state");
    //         }
    //     }
    // }
}

void ReceiveMessage(string message) {
    TokenIterator token_iter;
    token_iter.Init();

    if(!token_iter.FindNextToken(message)) {
        return;
    }

    string token = token_iter.GetToken(message);

    // if(token != "tutorial" && token != "added_object" && token != "notify_deleted") {
    //     Log(warning, "------------------------------- LEVEL HOOK GOT MESSAGE: " + message);
    // }

    if(token == "notify_deleted") {
        if(token_iter.FindNextToken(message)) {
            int delete_id = atoi(token_iter.GetToken(message));
            Object@ deleted_obj = ReadObjectFromID(delete_id);

            if(deleted_obj.GetType() == _hotspot_object) {
                for(int i = 0; i < GetNumHotspots(); i++) {  // TODO: Switch to cast now that David added it
                    Hotspot@ hotspot = ReadHotspot(i);

                    if(hotspot.GetID() == delete_id) {
                        if(hotspot.GetTypeString() == "hotspot_logic") {
                            deleted_obj.ReceiveScriptMessage("hotspot_logic_notify_deleted");
                        }
                        break;
                    }
                }
            }
        }
    } else if(token == "character_knocked_out" || token == "character_died") {
        for(int i = 0; i < GetNumHotspots(); i++) {
            Hotspot@ hotspot = ReadHotspot(i);

            if(hotspot.GetTypeString() == "hotspot_logic") {
                ReadObjectFromID(hotspot.GetID()).ReceiveScriptMessage("hotspot_logic_" + message);
            }
        }
    }
}

void DrawGUI() {
}

void SetWindowDimensions(int width, int height) {
}
