/* =======================================*/
/**
 * @Description: function 
 *
 * @Param: start
 * @Param: end = start if end == undefined
 *
 * @return String
 */
/* =======================================*/
String.prototype.remove = function(start, length) {
    if (length == undefined) length = 1;
    var delta_str = this.substr(start, length);
    return this.replace(delta_str, '');
};

/* =======================================*/
/**
 * @Description: function 
 *
 * @Param: old_str
 * @Param: new_str
 *
 * @return Array
 */
/* =======================================*/
var get_delta = function(old_str, new_str) {
    var result_list = [];
    var delta = '';
    var deling_index = 0;
    var contr = function(index) {
        while (new_str[index] != old_str[index]) {
            delta += new_str[index];
            new_str = new_str.remove(index);
        }
    };
    var deling = function(i) {
        deling_index = old_str.indexOf(new_str[i]);
        if (deling_index != -1) {
            old_str = old_str.remove(deling_index);
            new_str = new_str.remove(i);
            deling(i);
        }
    };
    for (i = 0; i < new_str.length; i++) {
        if (old_str.length) {
            deling(i);
        }
    }
    return [old_str, new_str];
};



jQuery.fn.label_fade = function(pre_name, callback) {
    return this.each(function() {
        var $this = $(this);
        if (!pre_name) {
            pre_name = '';
        }
        $this.on('keyup', function(e) {
            var for_name = pre_name + $this.attr('name');
            var $for_label = $this.parent().find('[for=' + for_name + ']');
            if($this.val()) {
                $for_label.fadeOut();
            }else{
                $for_label.fadeIn();
            }
        });
        if(typeof(callback) != 'undefined'){ callback(this); }
    });
}

jQuery.fn.default_text = function(default_text, callback) {
    return this.each(function() {
        var $this = $(this);
        $this.on('focus', function(e) {
            if (!$this.val()) {
                $this.val(default_text);
                $this.trigger('keyup');
            }
        }).on('blur', function(e) {
            if ($this.val() && $this.val() == default_text) {
                $this.val('');
                $this.trigger('keyup');
            }
        });
        if(typeof(callback) != 'undefined'){ callback(this); }
    });
}
