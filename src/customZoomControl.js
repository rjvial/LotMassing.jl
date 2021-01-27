class CustomZoomControl {

    onAdd(map) {
        this.map = map;

        this.container = document.createElement('div');
        this.container.className = " mapboxgl-ctrl mapboxgl-ctrl-group";

        this.input = document.createElement('input');
        this.input.type = "range"
        this.input.min = 80;
        this.input.max = 220;
        this.createAttribute(this.input, "value", map.getZoom()*10)
        this.input.className = "slider";
        this.input.id = "myRange";

        this.container.appendChild(this.input);

        // Update the current slider value (each time you drag the slider handle)
        this.input.oninput = function () {
            map.setZoom(this.value / 10);
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
        let zoom = map.getZoom()*10;
        if (this.input.value != zoom) this.input.value = zoom;
    }

}