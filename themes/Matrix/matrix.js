var matrix = {
    drops: [],
    chars: "0123456789ABCDEF",
    fontSize: 14,
    color: "#00ff9c",

    init: function (width, height) {
        this.drops = [];
        var columns = Math.floor(width / this.fontSize);
        for (var x = 0; x < columns; x++) {
            this.drops[x] = Math.random() * height / this.fontSize;
        }
    },

    drawMatrix: function (ctx, width, height) {
        if (!this.drops.length) {
            this.init(width, height);
        }

        ctx.fillStyle = "rgba(0, 0, 0, 0.07)";
        ctx.fillRect(0, 0, width, height);

        ctx.fillStyle = this.color;
        ctx.font = this.fontSize + "px 'JetBrainsMono Nerd Font Propo'";

        for (var i = 0; i < this.drops.length; i++) {
            var text = this.chars.charAt(Math.floor(Math.random() * this.chars.length));
            ctx.fillText(text, i * this.fontSize, this.drops[i] * this.fontSize);

            if (this.drops[i] * this.fontSize > height && Math.random() > 0.975) {
                this.drops[i] = 0;
            }
            this.drops[i]++;
        }
    },

    setColor: function(newColor) {
        this.color = newColor;
    }
};
