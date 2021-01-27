class CustomPredioControl {

    onAdd(map) {
        this.map = map;

        this.container = document.createElement('div');
        this.container.className = " mapboxgl-ctrl mapboxgl-ctrl-group";

        this.input = document.createElement('input');
        this.input.type = "range"
        this.input.min = 0;
        this.input.max = 50000;
        this.createAttribute(this.input, "value", 1000)  //map.getStyle().layers.find(x => x.id === 'layer_predios_filter').filter[2]
        this.input.className = "slider";
        this.input.id = "myRange";

        this.container.appendChild(this.input);

        // Update the current slider value (each time you drag the slider handle)
        this.input.oninput = function () {
            map.setZoom(this.value);
        }

        return this.container;
    }
    onRemove() {
        this.container.parentNode.removeChild(this.container);
        this.map = undefined;
    }

    createAttribute(obj, attrName, attrValue) {
        var att = document.createAttribute(attrName);
        att.value = attrValue;
        obj.setAttributeNode(att);
    }

    update() {
        let predioSize = map.getStyle().layers.find(x => x.id === 'layer_predios_filter').filter[2];
        if (this.input.value != predioSize) this.input.value = predioSize;
    }

}