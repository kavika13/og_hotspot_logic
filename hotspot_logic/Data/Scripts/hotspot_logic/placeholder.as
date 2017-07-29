const string k_placeholder_object_path = "Data/Objects/placeholder/empty_placeholder.xml";

enum PlacholderType {
    kGenericTerminalPlaceholder = 0,
    kHotspotInputTerminalPlaceholder = 1,
};

// --- Placeholder Instance ---

class Placeholder {
    PlacholderType type;
    int id = -1;
    string id_storage_param_name = "";
    string id_storage_param_value = "";
    vec3 offset = vec3(0);
};

Placeholder@ CreatePlaceholder(
        PlacholderType type, Object@ owner, ScriptParams@ params, string id_storage_param_name,
        string label, string editor_display_name, vec3 offset = vec3(0)) {
    Placeholder result;
    result.type = type;
    result.id_storage_param_name = id_storage_param_name;
    result.offset = offset;
    LoadOrCreatePlaceholder(result, owner, params, label, editor_display_name);
    return result;
}

void LoadOrCreatePlaceholder(
        Placeholder@ placeholder, Object@ owner, ScriptParams@ params, string label, string editor_display_name) {
    int id = placeholder.id;

    if(params.HasParam(placeholder.id_storage_param_name)) {
        id = atoi(params.GetString(placeholder.id_storage_param_name));
    }

    bool is_new_obj;
    Object@ obj = LoadOrCreatePlaceholderObject(id, is_new_obj);
    id = obj.GetID();

    SetPlaceholderState(obj, placeholder.type == kHotspotInputTerminalPlaceholder);  // TODO: Use a switch, maybe just pass on
    SetPlaceholderEditorLabel(obj, label, 3);
    SetPlaceholderEditorDisplayName(obj, editor_display_name);

    string new_id_storage_param_value = "" + id;
    placeholder.id = id;
    placeholder.id_storage_param_value = new_id_storage_param_value;
    params.SetString(placeholder.id_storage_param_name, new_id_storage_param_value);        

    if(is_new_obj) {
        UpdatePlaceholderTransform(placeholder, owner);        
    }
}

Object@ LoadOrCreatePlaceholderObject(int id, bool &out created) {
    if(id != -1 && ObjectExists(id)) {
        Object@ obj = ReadObjectFromID(id);

        if(obj.GetType() == _placeholder_object) {
            return obj;
        }
    }

    int new_id = CreateObject(k_placeholder_object_path, false);

    return ReadObjectFromID(new_id);
}

bool SetPlaceholderAllowedConnectionTypes(Placeholder@ placeholder, const EntityType[]@ allowed_types) {
    int id = placeholder.id;
    return SetPlaceholderAllowedConnectionTypes_(id, allowed_types);
}

void ProtectPlaceholderParams(Placeholder@ placeholder, ScriptParams@ params) {
    params.AddString(placeholder.id_storage_param_name, "");
    string updated_placeholder_ids = params.GetString(placeholder.id_storage_param_name);

    if(updated_placeholder_ids != placeholder.id_storage_param_value) {
        params.SetString(placeholder.id_storage_param_name, placeholder.id_storage_param_value);
    }
}

void ResetPlaceholderEditorLabel(Placeholder@ placeholder, string label) {
    int id = placeholder.id;

    if(id != -1 && ObjectExists(id)) {
        Object@ target_placeholder = ReadObjectFromID(id);
        SetPlaceholderEditorLabel(target_placeholder, label, 3);
    }
}

void ResetPlaceholderEditorDisplayName(Placeholder@ placeholder, string editor_display_name) {
    int id = placeholder.id;

    if(id != -1 && ObjectExists(id)) {
        Object@ target_placeholder = ReadObjectFromID(id);
        SetPlaceholderEditorDisplayName(target_placeholder, editor_display_name);
    }
}

void UpdatePlaceholderParentConnection(Placeholder@ placeholder, Object@ owner) {
    int id = placeholder.id;

    if(id != -1 && ObjectExists(id)) {
        Object@ obj = ReadObjectFromID(id);
        obj.ConnectTo(owner);
    }
}

void UpdatePlaceholderTransform(Placeholder@ placeholder, Object@ owner) {
    vec4 v = owner.GetRotationVec4();
    quaternion quat(v.x, v.y, v.z, v.a);

    int id = placeholder.id;

    if(id != -1 && ObjectExists(id)) {
        Object@ target_placeholder = ReadObjectFromID(id);
        target_placeholder.SetTranslation(
            owner.GetTranslation() +
            Mult(quat, GetPlaceholderPos(owner, placeholder.offset)));
        target_placeholder.SetRotation(quat);
        target_placeholder.SetScale(owner.GetScale() * 0.3f);
    }
}

vec3 GetPlaceholderPos(Object@ owner, vec3 offset) {
    return vec3(
        offset.x * owner.GetScale().x * 2.0f,
        (offset.y + 1.1f) * owner.GetScale().y * 2.0f,
        offset.z * owner.GetScale().z * 2.0f);
}

Object@ GetPlaceholderTarget(Placeholder@ placeholder) {
    Object@ placeholder_obj = ReadObjectFromID(placeholder.id);
    PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(placeholder_obj);
    int target_id = inner_placeholder_object.GetConnectID();

    if(target_id != -1 && ObjectExists(target_id)) {
        return ReadObjectFromID(target_id);
    } else {
        return null;
    }
}

void SendPlaceholderTargetScriptMessage(Placeholder@ placeholder, Object@ owner) {
    RelayScriptMessageToPlaceholderTarget(GetPlaceholderTarget(placeholder), owner);
}

void LogPlaceholderState(Placeholder@ placeholder, Object@ owner) {
    Log(info, "owner_id: " + owner.GetID());
    Log(info, "id_storage_param_name: " + placeholder.id_storage_param_name);
    Log(info, "id_storage_param_value: " + placeholder.id_storage_param_value);

    int id = placeholder.id;

    if(id != -1 && ObjectExists(id)) {
        Object@ obj = ReadObjectFromID(id);

        if(obj.GetType() == _placeholder_object) {
            PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(obj);
            Log(info, "" + id + " - conntected to: " + inner_placeholder_object.GetConnectID());
        } else {
            Log(warning, "object is not a _placeholder_object instance: " + id + " - type: " + obj.GetType());
        }
    } else {
        Log(warning, "object does not exist: " + id);
    }
}

void DisposePlaceholder(Placeholder@ placeholder) {
    if(placeholder.id != -1) {
        DeleteObjectID(placeholder.id);
        placeholder.id = -1;        
    }
}

// --- Placeholder Array ---

enum PlacholderArrayLayout {
    kHorizontalPlaceholderArrayLayout = 0,
    kVerticalPlaceholderArrayLayout = 1,
};

class PlaceholderArray {
    int[] ids;
    string id_storage_param_name = "";
    string id_storage_param_value = "";
    vec3 offset = vec3(0);
    PlacholderArrayLayout layout;
};

PlaceholderArray@ CreatePlaceholderArray(
        ScriptParams@ params, string id_storage_param_name,
        string label, string editor_display_name, vec3 offset = vec3(0), PlacholderArrayLayout layout = kHorizontalPlaceholderArrayLayout) {
    PlaceholderArray result;
    result.id_storage_param_name = id_storage_param_name;
    result.offset = offset;
    result.layout = layout;
    LoadPlaceholderArrayFromStorageParam(result, params, label, editor_display_name);
    return result;
}

void LoadPlaceholderArrayFromStorageParam(
        PlaceholderArray@ placeholder_array, ScriptParams@ params, string label, string editor_display_name) {
    if(params.HasParam(placeholder_array.id_storage_param_name)) {
        string old_id_storage_param_value = params.GetString(placeholder_array.id_storage_param_name);
        string new_id_storage_param_value = "";

        TokenIterator token_iter;
        token_iter.Init();
        int count = 0;

        while(token_iter.FindNextToken(old_id_storage_param_value)) {
            int id = atoi(token_iter.GetToken(old_id_storage_param_value));

            if(id != -1 && ObjectExists(id)) {
                Object@ obj = ReadObjectFromID(id);

                if(obj.GetType() == _placeholder_object) {
                    SetPlaceholderState(obj);
                    if(count == 0) {
                        SetPlaceholderEditorLabel(obj, label);
                    }
                    SetPlaceholderEditorDisplayName(obj, editor_display_name + " " + (count + 1));
                    new_id_storage_param_value += (count > 0 ? ", " : "") + id;
                    placeholder_array.ids.insertLast(id);
                    ++count;
                }
            }
        }

        placeholder_array.id_storage_param_value = new_id_storage_param_value;
        params.SetString(placeholder_array.id_storage_param_name, new_id_storage_param_value);
    }
}

bool SetPlaceholderArrayAllowedConnectionTypes(PlaceholderArray@ placeholder_array, const EntityType[]@ allowed_types) {
    bool result = true;

    for(uint i = 0, len = placeholder_array.ids.length(); i < len; i++) {
        int id = placeholder_array.ids[i];
        result = result && SetPlaceholderAllowedConnectionTypes_(id, allowed_types);
    }

    return result;
}

uint GetPlaceholderArrayCount(PlaceholderArray@ placeholder_array) {
    return placeholder_array.ids.length();
}

void ProtectPlaceholderArrayParams(PlaceholderArray@ placeholder_array, ScriptParams@ params) {
    params.AddString(placeholder_array.id_storage_param_name, "");
    string updated_placeholder_ids = params.GetString(placeholder_array.id_storage_param_name);

    if(updated_placeholder_ids != placeholder_array.id_storage_param_value) {
        params.SetString(placeholder_array.id_storage_param_name, placeholder_array.id_storage_param_value);
    }
}

void SyncPlaceholderArrayInstances(
        PlaceholderArray@ placeholder_array, ScriptParams@ params, Object@ owner, int target_count, string label, string editor_display_name) {
    int previous_count = int(placeholder_array.ids.length());

    if(target_count > previous_count) {
        AddPlaceholderArrayInstances(placeholder_array, params, owner, target_count, label, editor_display_name);
    } else if(target_count < previous_count) {
        RemovePlaceholderArrayInstances(placeholder_array, params, target_count);
    }
}

void AddPlaceholderArrayInstances(
        PlaceholderArray@ placeholder_array, ScriptParams@ params, Object@ owner, int new_count, string label, string editor_display_name) {
    int previous_count = int(placeholder_array.ids.length());
    new_count = max(new_count, 0);

    int to_add_count = new_count - previous_count;

    for(int i = 1; i <= to_add_count; i++) {
        int current_target_index = i + previous_count;
        int new_target_placeholder_id = CreateObject(k_placeholder_object_path, false);

        Object@ new_target_placeholder = ReadObjectFromID(new_target_placeholder_id);
        SetPlaceholderState(new_target_placeholder);
        if(current_target_index == 1) {
            SetPlaceholderEditorLabel(new_target_placeholder, label);
        }
        SetPlaceholderEditorDisplayName(new_target_placeholder, editor_display_name + " " + current_target_index);
        placeholder_array.ids.insertLast(new_target_placeholder_id);
        placeholder_array.id_storage_param_value += (i > 1 || previous_count > 0 ? ", " : "") + new_target_placeholder_id;
    }

    params.SetString(placeholder_array.id_storage_param_name, placeholder_array.id_storage_param_value);

    UpdatePlaceholderArrayTransforms(placeholder_array, owner);
}

void RemovePlaceholderArrayInstances(PlaceholderArray@ placeholder_array, ScriptParams@ params, int new_count) {
    int previous_count = int(placeholder_array.ids.length());
    new_count = max(new_count, 0);

    for(int i = new_count; i < previous_count; i++) {
        DeleteObjectID(placeholder_array.ids[i]);
    }

    string new_id_storage_param_value = "";
    for(int i = 0; i < new_count; ++i) {
        new_id_storage_param_value += (i > 0 ? ", " : "") + placeholder_array.ids[i];
    }

    placeholder_array.id_storage_param_value = new_id_storage_param_value;
    params.SetString(placeholder_array.id_storage_param_name, new_id_storage_param_value);

    placeholder_array.ids.resize(new_count);
}

void ResetPlaceholderArrayEditorLabel(PlaceholderArray@ placeholder_array, string label) {
    if(placeholder_array.ids.length() > 0) {
        int id = placeholder_array.ids[0];

        if(id != -1 && ObjectExists(id)) {
            Object@ target_placeholder = ReadObjectFromID(id);
            SetPlaceholderEditorDisplayName(target_placeholder, label);
        }
    }
}

void ResetPlaceholderArrayEditorDisplayNames(PlaceholderArray@ placeholder_array, string editor_display_name) {
    for(uint i = 0; i < placeholder_array.ids.length(); i++) {
        int id = placeholder_array.ids[i];

        if(id != -1 && ObjectExists(id)) {
            Object@ target_placeholder = ReadObjectFromID(id);
            SetPlaceholderEditorDisplayName(target_placeholder, editor_display_name + " " + (i + 1));
        }
    }
}

void UpdatePlaceholderArrayTransforms(PlaceholderArray@ placeholder_array, Object@ owner) {
    uint placeholder_count = placeholder_array.ids.length();
    vec4 v = owner.GetRotationVec4();
    quaternion quat(v.x, v.y, v.z, v.a);

    for(uint i = 0; i < placeholder_count; i++) {
        int id = placeholder_array.ids[i];

        if(id != -1 && ObjectExists(id)) {
            Object@ target_placeholder = ReadObjectFromID(id);
            target_placeholder.SetTranslation(
                owner.GetTranslation() +
                Mult(quat, GetArrayPlaceholderPos(
                    owner, placeholder_array.offset, placeholder_array.layout, placeholder_count, i + 1)));
            target_placeholder.SetRotation(quat);
            target_placeholder.SetScale(owner.GetScale() * 0.3f);
        }
    }
}

vec3 GetArrayPlaceholderPos(Object@ owner, vec3 offset, PlacholderArrayLayout layout, int instance_count, int current_index) {
    if(layout != kVerticalPlaceholderArrayLayout) {  // TODO: Use a switch
        return vec3(
            (instance_count * 0.5f + 0.5f - current_index) * owner.GetScale().x * 0.35f +
                offset.x * owner.GetScale().y * 2.0f,
            (offset.y + 1.1f) * owner.GetScale().y * 2.0f,
            offset.z * owner.GetScale().z * 2.0f);
    } else {
        return vec3(
            offset.x * owner.GetScale().y * 2.0f,
            (current_index - 1.0f) * owner.GetScale().y * 0.35f +
                (offset.y + 1.1f) * owner.GetScale().y * 2.0f,
            offset.z * owner.GetScale().z * 2.0f);
    }
}

Object@ GetPlaceholderArrayTargetAtIndex(PlaceholderArray@ placeholder_array, uint index) {
    Object@ placeholder = ReadObjectFromID(placeholder_array.ids[index]);
    PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(placeholder);
    int target_id = inner_placeholder_object.GetConnectID();

    if(target_id != -1 && ObjectExists(target_id)) {
        return ReadObjectFromID(target_id);
    }

    return null;
}

void SendScriptMessageToPlaceholderArrayTargets(PlaceholderArray@ placeholder_array, Object@ owner) {
    for(uint i = 0; i < placeholder_array.ids.length(); i++) {
        RelayScriptMessageToPlaceholderTarget(GetPlaceholderArrayTargetAtIndex(placeholder_array, i), owner);
    }
}

void LogPlaceholderArrayState(PlaceholderArray@ placeholder_array, Object@ owner) {
    uint placeholder_count = placeholder_array.ids.length();

    Log(info, "owner_id: " + owner.GetID());
    Log(info, "id_storage_param_name: " + placeholder_array.id_storage_param_name);
    Log(info, "id_storage_param_value: " + placeholder_array.id_storage_param_value);
    Log(info, "ids count: " + placeholder_count);

    for(uint i = 0; i < placeholder_count; i++) {
        int id = placeholder_array.ids[i];

        if(id != -1 && ObjectExists(id)) {
            Object@ obj = ReadObjectFromID(id);

            if(obj.GetType() == _placeholder_object) {
                PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(obj);
                Log(info, "" + id + " - conntected to: " + inner_placeholder_object.GetConnectID());
            } else {
                Log(warning, "object is not a _placeholder_object instance: " + id + " - type: " + obj.GetType());
            }
        } else {
            Log(warning, "object does not exist: " + id);
        }
    }
}

void DisposePlaceholderArray(PlaceholderArray@ placeholder_array) {
    for(uint i = 0; i < placeholder_array.ids.length(); i++) {
        DeleteObjectID(placeholder_array.ids[i]);
    }

    placeholder_array.ids.resize(0);
}

// --- Per instance setup ---

void SetPlaceholderState(Object@ target_placeholder, bool is_input_for_hotspot = false) {
    PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(target_placeholder);
    inner_placeholder_object.SetSpecialType(kPlayerConnect);

    if(is_input_for_hotspot) {
        inner_placeholder_object.SetConnectToTypeFilterFlags(uint64(1) << _hotspot_object);
    } else {
        inner_placeholder_object.SetConnectToTypeFilterFlags(
            inner_placeholder_object.GetConnectToTypeFilterFlags() | (uint64(1) << _placeholder_object));
    }

    target_placeholder.SetSelectable(true);
    target_placeholder.SetCopyable(false);
    target_placeholder.SetDeletable(false);
    // TODO: Are the rest of these redundant?
    target_placeholder.SetTranslatable(false);
    target_placeholder.SetRotatable(false);
    target_placeholder.SetScalable(false);
}

bool SetPlaceholderAllowedConnectionTypes_(int object_id, const EntityType[]@ allowed_types) {
    bool result = false;

    if(object_id != -1 && ObjectExists(object_id)) {
        Object@ target_placeholder = ReadObjectFromID(object_id);

        if(target_placeholder.GetType() == _placeholder_object) {
            PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(target_placeholder);
            uint64 flags = 0;

            for(uint i = 0, len = allowed_types.length(); i < len; i++) {
                flags = flags | (uint64(1) << allowed_types[i]);
            }

            inner_placeholder_object.SetConnectToTypeFilterFlags(flags);
            result = true;
        }
    }

    if(!result) {
        Log(warning, "Failed to set allowed connection flags for object: " + object_id);
    }

    return result;
}

void SetPlaceholderEditorLabel(Object@ target_placeholder, string label_value, int scale = 6) {
    target_placeholder.SetEditorLabel(label_value);
    target_placeholder.SetEditorLabelScale(scale);
    target_placeholder.SetEditorLabelOffset(vec3(0));
}

void SetPlaceholderEditorDisplayName(Object@ target_placeholder, string editor_display_name) {
    PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(target_placeholder);
    inner_placeholder_object.SetEditorDisplayName(editor_display_name);
}

void RelayScriptMessageToPlaceholderTarget(Object@ target_obj, Object@ owner) {
    if(target_obj is null || !ObjectExists(target_obj.GetID())) {
        return;
    }

    int target_id = target_obj.GetID();

    array<int> visited_objects;
    visited_objects.insertLast(target_obj.GetID());

    while(!(target_obj is null)) {
        if(target_obj.GetType() == _placeholder_object) {
            PlaceholderObject@ inner_placeholder_object = cast<PlaceholderObject@>(target_obj);
            int chained_target_id = inner_placeholder_object.GetConnectID();

            if(chained_target_id == -1 || !ObjectExists(chained_target_id)) {
                break;
            }

            Object@ chained_target = ReadObjectFromID(chained_target_id);

            if(!(visited_objects.find(chained_target_id) < 0)) {
                Log(warning, "Hit loop, cancelling sending message through this object: " + target_id);
                break;
            }

            @target_obj = @chained_target;
            visited_objects.insertLast(chained_target_id);
        } else {
            target_obj.QueueScriptMessage("hotspot_logic_triggered " + target_id + " " + owner.GetID());
            break;
        }
    }
}
