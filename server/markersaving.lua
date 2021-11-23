RegisterNetEvent("loaf_lib:saveMarkers")
AddEventHandler("loaf_lib:saveMarkers", function(markers)
    SaveResourceFile(GetCurrentResourceName(), "markers.json", json.encode(markers))
end)