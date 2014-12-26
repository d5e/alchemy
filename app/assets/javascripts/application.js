// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery-ui
//= require turbolinks
//= require_tree .
// ### require bootstrap-sprockets

//= require jquery_nested_form


function localeToFloat(string) {
    if (typeof string == 'number')
        return string;
    if ( 'de' == $('html').attr('lang'))
        string = string.replace(/\./g,'').replace(/,/g,'.');
    else
        string = string.replace(/\,/g,'')
    return parseFloat(string);
}

function floatToLocale(number, precision) {
    string = ( (precision) ? number = number.toFixed(precision) : number + "" );
    if ( 'de' == $('html').attr('lang'))
        string = string.replace(/\./g,',')
    return string;
}

function initCharacterLegendHighlighting() {
    console.log("yo");
    if ( 0 == $('#content div.character-legend').length)
        return null;
    window.characterLegends = $('#content div.character-legend');
    $('#content .buttons-container').on('mouseenter', 'a.btn[class*="color-"]', function(e) {
        var button = $(this);
        var color = (button.attr('class') + "").match(/color-[^\s]+/)[0];
//        $(window.characterLegends).find('.label').removeClass('highlighted');
        $(window.characterLegends).find('.label.' + color).addClass('highlighted');
    });
    $('#content .buttons-container').on('mouseleave', 'a.btn[class*="color-"]', function(e) {
        $(window.characterLegends).find('.label').removeClass('highlighted');
    });

}

    
window.runAfterInit = function(){

    console.log("JS ready : initializing");

    $('[data-toggle="tooltip"]:visible').tooltip(
        { delay: 180}
    );

    $('[data-tooltip=click').tooltip(
        { trigger: 'click' }
    );
    
    $('body').on('click', '[data-toggle=highlight]', function(e) {
       $(this).toggleClass('highlighted');
       var hiddenField = null;
       if (hiddenField = $(this).parent().find('input[type=hidden].highlight'))
            hiddenField.val( $(this).hasClass('highlighted') ? '1' : '0' )
    });
    
    $('body').on('click', 'a[data-toggle="invert-highlighted"]', function(e) {
       $(this).parent().find('[data-toggle=highlight]').trigger('click');
    });
    
    
    
    
    
    
    // character legend highlighting
    
    initCharacterLegendHighlighting();
    
    
    
    
    
    
    
    
    
    $('#resize-wizard').on('click', 'form ul.nav.nav-tabs a', function(e) {
        var href = $(this).attr('href');
        $('#resize-wizard form input[type=hidden][name="strategy"]').val(href);
    });
    
    
    
    // $('#mix-ingredients').on('change', 'input[type=text]', function(e) {
    //     alert('yo');
    // });
    
    
    
    
    // SEPARATOR
    
    $( ".draggable" ).draggable();
    $( ".droppable" ).droppable({
        drop: function( event, ui ) {
            console.log(event);
            console.log(ui);
            $( this )
                .find( ".panel-body" ).append(" ").append(ui.draggable);
                ui.draggable.css('left','auto');
                ui.draggable.css('top','auto');
            }
    });
    
    $('form.blends-separator').on("click", "span[type='ajax-submit']", function(e) {
        window.Separator = {};
        $('form.blends-separator .panel[data-category-name]').each(function(i,panel){
            window.Separator[$(panel).attr('data-category-name')] = [];
        });
        $('form.blends-separator .panel[data-category-name] .draggable[data-resource-id]').each(function(i,substance){
            var substance = $(substance);
            var panel = substance.closest('.panel[data-category-name]');
            window.Separator[$(panel).attr('data-category-name')].push($(substance).attr('data-resource-id'));
        });
        
        
        $.ajax({
            type: "POST",
            url: $(this).closest('form').attr('action'),
            data: { 'separator' : window.Separator },
            success: function(r) {
                // alert('200');
            }
        
        });
        
    });
    
    
    
    

    
    $('form').on('change', 'select.form-control.substance.having-dilution-select', function(e) {
        var selected = "";
        var substanceID = $(this).val();
        if (!(substanceID > 0)) return;
        var parent = $(this).closest('.form-group');
        var dilutionSelect = parent.find('select.form-control.dilution.need-filtering');
        var dilutionSelectedVal = dilutionSelect.val();
        dilutionSelect.find('option').remove();
        var dilutions = eval(" window.availableDilutions.s" + substanceID);
        if (!dilutions) {
            dilutionSelect.append('<option value>no dilution available</option>');
            return;
        }
        dilutionSelect.append('<option value>please select</option>');
        dilutions.forEach(function(dil) {
            console.log(dil);
            selected = " ";
            if (dilutionSelectedVal == dil.dilution_id)
                selected = " selected "
            dilutionSelect.append('<option value="' + dil.dilution_id + '" ' + selected + '>' + dil.dilution_name + '</option>');
         });
         
     });

    $('form').on('change', '.dilution-wizard select.dilution.wizard', function(e) {
        var sd = $(this);
        var parent = sd.closest('.form-group.dilution-wizard');
        var amount = parent.find('input[data-concentration]');
        var old_concentration = parseFloat(amount.attr('data-concentration'));
        var new_concentration = parseFloat(sd.find('option:selected').attr('data-concentration'));
        if (old_concentration == 0.0 || new_concentration == 0.0)
            return;
        var scale = old_concentration / new_concentration;
        amount.val( floatToLocale(localeToFloat(amount.val()) * scale) );
        amount.attr('data-concentration', new_concentration);
    });

    $('form').on('click', '.btn-group a[data-color-selector="list"]', function(e) {
        var cs = $(this);
        var parent = cs.closest('.btn-group');
        var hidden = parent.find('input[type="hidden"]');
        var button = parent.find('button[data-color-selector="list"]')
        var name = cs.attr('data-name');
        button.find('span.name').text(name.toUpperCase());
        hidden.val(name);
        var oldc = button.attr('class');
        if (!oldc)            return;
        var nc = oldc.replace(/color\-\w+/,'')
        console.log(nc);
        button.attr('class',  nc);
        button.addClass('color-' + name);
    });

    $('[data-colorpicker="flat"]').ColorPicker({
        flat: true,
        color: $('input[data-colorpicker]').val() || '#ffffff',
        onShow: function (colpkr) {
            $(colpkr).fadeIn(500);
            return false;
        },
        onHide: function (colpkr) {
            $(colpkr).fadeOut(500);
            return false;
        },
        onChange: function (hsb, hex, rgb) {
//            $('#colorSelector div').css('backgroundColor', '#' + hex);
            console.log(hex);
        },
        onSubmit: function (hsb, hex, rgb) {
//            $('#colorSelector div').css('backgroundColor', '#' + hex);
            console.log(" sub: " + hex);
            $('[data-colorpicker="flat"]').hide();
            if (hex == "ffffff")
                hex = "";
            $('input[data-colorpicker]').val(hex);
            $('[data-colorpicker="button"]').css('background-color', '#' + hex);
        }
    });

    $('[data-colorpicker="button"]').on('click', function(e) {
        $('[data-colorpicker="flat"]').toggle();
    });
    
    
    // BLENDS MIXER
    
    $('form.blends-mixer, form.family-batch-add').on("click", ".available-blends [data-blend-dom-id], .selected-blends [data-blend-dom-id]", function(e) {
        var me = $(this);
        var form = me.closest('form');
        var dom_id = me.attr('data-blend-dom-id');
        form.find('input#selected_blend_ids[type="hidden"]').toggleClass(dom_id);
        var targetContainer = null;
        if (me.closest('.available-blends').length > 0)
            targetContainer = form.find(".selected-blends");
        else
            targetContainer = form.find(".available-blends");
        targetContainer.append(me);
        targetContainer.append(" ");
        
        if (form.find('input#selected_blend_ids[type="hidden"]').attr('class').length > 2)
            form.find('button[type="submit"]').removeClass('disabled')
        else
            form.find('button[type="submit"]').addClass('disabled')
    });

    $('form.blends-mixer, form.family-batch-add').on("submit", function(e) {
        var me = $(this);
        var hidden = me.find('input#selected_blend_ids[type="hidden"]');
        hidden.val(hidden.attr('class'));
    });

    $('body').on('keyup', 'form .has-error input', function(e) {
        $(this).closest('.has-error').removeClass('has-error');
    });

};

jQuery(document).ready(window.runAfterInit);

$(document).on("page:load", window.runAfterInit);





/***************************    IE    ***************************/

/* do nothing on call console if console not exists */
if (!window.console)
    window.console = {
        log : function(str) {},
        debug : function(str) {},
        warn : function(str) { alert("console.warn: " + str); }
    };
