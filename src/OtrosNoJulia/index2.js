mapboxgl.accessToken = 'pin aqui';

var map = new mapboxgl.Map({
    container: 'before',
    style: 'mapbox://styles/mapbox/streets-v11',
    center: [-70.628, -33.447],
    zoom: 10.75
});

var afterMap = new mapboxgl.Map({
    container: 'after',
    style: 'mapbox://styles/mapbox/satellite-v9',
    center: [-70.628, -33.447],
    zoom: 10.75
});

// Create a popup, but don't add it to the map yet.
var popup = new mapboxgl.Popup({
    closeButton: false
});


// wait for map to load before adjusting it
map.on('load', function () {

    map.addControl(new MapboxGeocoder({ accessToken: mapboxgl.accessToken, mapboxgl: mapboxgl }), 'top-left');

    // A selector or reference to HTML element
    var container = '#comparison-container';
    var mapContainer = new mapboxgl.Compare(map, afterMap, container, {});
    //Set Position - this will set the slider at the specified (x) number of pixels from the left-edge or top-edge of viewport based on swiper orientation
    mapContainer.setSlider(1550);

    // Add zoom slider control.
    let zoomControl = new CustomZoomControl();
    map.addControl(zoomControl, 'top-left');
    map.on('zoom', function () {
        zoomControl.update();
    });

    // Add predio slider control.
    let predioControl = new CustomPredioControl();
    map.addControl(predioControl, 'top-left');
//    map.on('zoom', function () {
//        predioControl.update();
//    });

    map.on()
    // Add draw controls
    var draw = new MapboxDraw({
        displayControlsDefault: false,
        controls: { polygon: true, trash: true }
    });
    map.addControl(draw, 'top-left');
    map.on('draw.create', updateArea);
    map.on('draw.delete', updateArea);
    map.on('draw.update', updateArea);

    // make a pointer cursor
    map.getCanvas().style.cursor = 'default';


    // ########### SOURCES AND LAYERS ###############
    map.addSource('estaciones', {
        'type': 'vector',
        'url': 'mapbox://rvial.0l83pos4'
    });
    map.addLayer(
        {
            'id': 'layer_estaciones',
            'type': 'circle',
            'source': 'estaciones',
            'source-layer': 'Estaciones_actuales_Metro_de_-anmsau',
            'layout': { 'visibility': 'visible' },
            'paint': {
                'circle-radius': 5,
                'circle-color': '#943b00',
                'circle-opacity': .75
            }
        },
        'settlement-label'
    );

    map.addSource('division_comunal', {
        'type': 'vector',
        'url': 'mapbox://rvial.9xa97bd7'
    });
    map.addLayer(
        {
            'id': 'layer_division_comunal',
            'type': 'line',
            'source': 'division_comunal',
            'source-layer': 'divisin_comunal-0fj888',
            'layout': { 'visibility': 'visible' },
            'paint': {
                'line-color': '#490303',
                'line-opacity': 1,
                'line-width': 3
            }
        },
        'settlement-label'
    );

    map.addSource('prc', {
        'type': 'vector',
        'url': 'mapbox://rvial.6mvu39fx'
    });
    map.addLayer(
        {
            'id': 'layer_prc_',
            'type': 'line',
            'source': 'prc',
            'source-layer': 'prc_Metropolitana3-2ks0t6',
            'layout': { 'visibility': 'visible' },
            'paint': {
                'line-color': '#de1212',
                'line-opacity': 1,
                'line-width': 1
            }
        },
        'settlement-label'
    );
    map.addLayer(
        {
            'id': 'layer_prc',
            'type': 'fill',
            'source': 'prc',
            'source-layer': 'prc_Metropolitana3-2ks0t6',
            'layout': { 'visibility': 'visible' },
            'paint': {
                'fill-outline-color': '#de1212',
                'fill-color': '#de1212',
                'fill-opacity': 0.01
            }
        },
        'settlement-label'
    );

    map.addSource('predios', {
        'type': 'vector',
        'url': 'mapbox://rvial.dgb3ug9n'
    });
    map.addLayer(
        {
            'id': 'layer_predios',
            'type': 'fill',
            'source': 'predios',
            'source-layer': 'Predios_Metropolitana-dj1vj9',
            'layout': { 'visibility': 'visible' },
            'paint': {
                'fill-outline-color': '#406482',
                'fill-color': '#16b6ab',
                'fill-opacity': 0.5
            }
        },
        'settlement-label'
    );
    map.addLayer(
        {
            'id': 'layer_predios_hover',
            'type': 'fill',
            'source': 'predios',
            'source-layer': 'Predios_Metropolitana-dj1vj9',
            'paint': {
                'fill-outline-color': '#406482',
                'fill-color': '#16b6ab',
                'fill-opacity': 1
            },
            'filter': ['in', 'id', '']
        },
        'settlement-label'
    );
    map.addLayer(
        {
            'id': 'layer_predios_selected',
            'type': 'fill',
            'source': 'predios',
            'source-layer': 'Predios_Metropolitana-dj1vj9',
            'paint': {
                'fill-outline-color': '#406482',
                'fill-color': '#f50a0a',
                'fill-opacity': .7
            },
            'filter': ['in', 'id', '']
        },
        'settlement-label'
    );
    map.addLayer(
        {
            'id': 'layer_predios_filter',
            'type': 'fill',
            'source': 'predios',
            'source-layer': 'Predios_Metropolitana-dj1vj9',
            'paint': {
                'fill-outline-color': '#406482',
                'fill-color': '#005194',
                'fill-opacity': 1
            },
            'filter': ['>=', 'Area', 1000]
        },
        'settlement-label'
    );

    map.addSource('edificios', {
        'type': 'vector',
        'url': 'mapbox://mapbox.mapbox-streets-v8'
    });
    map.addLayer({
        'id': 'layer_edificios',
        'type': 'fill',
        'source': 'edificios',
        'source-layer': 'building',
        'layout': {
            'visibility': 'visible'
        },
        'paint': {
            'fill-outline-color': '#292424',
            'fill-color': '#f91010',
            'fill-opacity': 0
        },
    },
        'settlement-label'
    );
    // ###########################################



    // Calcula el area de polygono dibujado y guarda coordenadas
    function updateArea(e) {
        var data = e.features[0].geometry.coordinates[0]
        if (data.length > 0) {
            var polygon = turf.polygon([data]);
            var area = turf.area(polygon);
            // restrict to area to 2 decimal points
            var rounded_area = Math.round(area * 100) / 100;
        }

        var polyData = [[rounded_area, 0]]
        for (let i = 0; i < data.length - 1; i++) {
            polyData.push([data[i][0], data[i][1]])
        }

        var fileName = prompt("Ingrese nombre del archivo", "ejemplo.csv");

        let csvContent = "data:text/csv;charset=utf-8,"
            + polyData.map(e => e.join(",")).join("\n");
        var encodedUri = encodeURI(csvContent);
        var link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", fileName);
        document.body.appendChild(link); // Required for FF
        link.click(); // This will download the data file named "my_data.csv".
    }


    // change info window on hover
    map.on('mousemove', 'layer_predios', function (e) {
        // Change the cursor style as a UI indicator.
        map.getCanvas().style.cursor = 'pointer';

        // Single out the first found feature.
        var feature = e.features[0];

        // Hover layer de predios.
        map.setFilter('layer_predios_hover', ['in', 'id', feature.properties.id]);

    });
    map.on('mouseleave', 'layer_predios', function () {
        map.getCanvas().style.cursor = '';
        map.setFilter('layer_predios_hover', ['in', 'id', '']);
        popup.remove();
    });

    map.on('click', function (e) {

        var features = map.queryRenderedFeatures(e.point, { layers: ['layer_predios', 'layer_prc'] });
        if (!features.length) {
            return;
        }

        map.setFilter('layer_predios_selected', ['in', 'id', features[0].properties.id]);

        var list = "<dl>"
            + "<dd>" + 'Comuna: ' + features[1].properties.COMUNA + "</dd>"
            + "<dd>" + 'Zona: ' + features[1].properties.ZONA + "</dd>"
            + "<dd>" + 'Descripción: ' + features[1].properties.NOMBRE + "</dd>"
            + "<dd>" + 'Area Predio: ' + Math.round(features[0].properties.Area).toLocaleString() + ' m2' + "</dd>"
            + "</dl>"
        new mapboxgl.Popup()
            .setLngLat(e.lngLat)
            .setHTML(list)
            .addTo(map);

        // Guarda coordenadas del predio al apretar ctrl + click
        if (e.originalEvent.ctrlKey) {
            var feature = e.features[0];
            var polyData = [[feature.properties.Area, 0]]

            for (let i = 0; i < feature.geometry.coordinates[0].length - 1; i++) {
                polyData.push([feature.geometry.coordinates[0][i][0], feature.geometry.coordinates[0][i][1]])
            }

            var fileName = prompt("Ingrese nombre del archivo", "ejemplo.csv");

            let csvContent = "data:text/csv;charset=utf-8,"
                + polyData.map(e => e.join(",")).join("\n");
            var encodedUri = encodeURI(csvContent);
            var link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", fileName);
            document.body.appendChild(link); // Required for FF
            link.click(); // This will download the data file named "my_data.csv".
        }
    });


});




