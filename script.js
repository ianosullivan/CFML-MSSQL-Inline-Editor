// Editor actions buttons
var editor_buttons = `			
						<div class="btn-group btn-group-sm js-editor-button-group" role="group">
							<button type="button" class="btn btn-success js-save" title="Save Changes">
								<i class="fa fa-fw fa-check"></i>
							</button>
							<button type="button" class="btn btn-danger js-cancel" title="Cancel and revert to original">
								<i class="fa fa-fw fa-times"></i>
							</button>
						</div>				
					`;

$(function() {
	//Create nice editors
	CreateInlineEditors();
	CreateInlineSelects();
});

function CreateInlineEditors(){	

	// Enhance tooltip title
	// $('.js-inline-editor').tooltip();

	// 'Activate' the editor on 'click'
	// $('.js-inline-editor').on('dblclick', function(e){
	$('body').on('click', '.js-inline-editor', function(e){
		var $this = $(this);

		// If this editor is not already 'active' proceed
		if( !$this.hasClass('active') ) {
			// Add action buttons after any editable content
			// Add the 'active' class, editable attribute and show the buttons
			$this
			.after(editor_buttons)
			.addClass('active')
			.attr('contenteditable', true)
			.attr('title', 'Press Esc to cancel changes')
			.focus();
			// .next().show()	
		}
	});

	// Generic function to save editable content. 
	$('body').on('click', '.js-inline-editor + div button.js-save', function(e){

		swal.showLoading();

		// e.preventDefault();
		console.log('js-save');

		// Get the ID and data/content from the relevant CKEditor object...
		var $button_container = $(this).parent();
		var $el = $button_container.prev(); //Get the actual editor DOM element. It is always the 'Prev' element to the buttons

		$.post('actions/act_save.cfm', 
		{	
			sull: $el.data('sull'),
			the_value: $el.text()
		})
		.done(function(data) {
			if(data.result){
				// 'Deactivate' the editor
				// Reset the element to the original value
				$el
				.removeClass('active')
				.removeAttr('contenteditable')
				.attr('title', 'Click to Edit')
				.data('originalValue', $el.text() );

				// remove the button container from the DOM
				$button_container.remove();
				
				successMessage();
			}
			else{
				failMessage(data.message);
			}
		})
		.fail(function(data){
			failMessage(data.message);
		})
	});


	// Generic function to cancel changes to editable content.
	$('body').on('click', '.js-inline-editor + div button.js-cancel', function(e){
		// e.preventDefault();
		console.log('js-cancel');

		// Destroy the buttons
		var $button_container = $(this).parent();
		var $el = $button_container.prev();

		cancelOrEscape($button_container, $el);
	});

	// escape key within the editor to cancel it
	$('body').on('keyup', '.js-inline-editor', function(e){

		if (e.key === 'Escape') {
			console.log('escape key pressed within editor');
			// Destroy the buttons
			var $button_container = $(this).next();
			var $el = $(this);

			cancelOrEscape($button_container, $el);
	    }
   	});
}

function CreateInlineSelects(){
	$('body').on('click','.js-inline-select', function(e){
		var $this = $(this);

		// If this editor is not already 'active' proceed
		if( !$this.hasClass('active') ) {
			// Add action buttons after any editable content
			// Add the 'active' class, editable attribute and show the buttons

			$this
			.addClass('active')
			.removeAttr('title')
			.html('<i>loading...</i>')
			.load('action/act_make_select.cfm', {sull: $this.data('sull')}, function(){
				$this
				.append(editor_buttons)
				.find('select').focus();
			});
		}
	});

	// Generic function to save inilne <select>
	$('body').on('click', '.js-inline-select div.js-editor-button-group button.js-save', function(e){
		e.stopPropagation();

		swal.showLoading();

		// e.preventDefault();
		console.log('js-save-select');

		// Get the ID and data/content from the relevant CKEditor object...
		var $button_container = $(this).parent();
		var $el = $button_container.prev(); //Get the actual <select> DOM element. It is always the 'Prev' element to the buttons
		var $el_parent = $el.parent(); //Get the span with the special data attributes

		$.post('action/act_save_select.cfm', 
		{	
			sull: $el_parent.data('sull'),
			the_value_id: $el.val()
		})
		.done(function(data) {
			if(data.result){
				// console.log(decodeURIComponent(data.new_select_span));
				var new_select_span = decodeURIComponent(data.new_select_span);

				$el_parent.replaceWith( new_select_span );

				// remove the button container from the DOM
				$button_container.remove();
				
				successMessage();
			}
			else{
				failMessage(data.message);
			}
		})
		.fail(function(data){
			failMessage(data.message);
		})
	});


	// Generic function to cancel changes to editable content.
	$('body').on('click', '.js-inline-select div.js-editor-button-group button.js-cancel', function(e){
		e.stopPropagation();

		// e.preventDefault();
		console.log('js-cancel-select');

		// Get the main element
		var $el_parent = $(this).parent().parent();

		// Reset the element to the original value
		cancelOrEscapeSelect($el_parent);
	});


	// escape key within the editor to cancel it
	$('body').on('keyup', '.js-inline-select select', function(e){

		if (e.key === 'Escape') {
			console.log('escape key pressed within <select>');
			// Destroy the buttons
			var $el_parent = $(this).parent();

			// Reset the element to the original value
			cancelOrEscapeSelect($el_parent);
	    }
   	});
}

function cancelOrEscape($button_container, $el){
	// remove the button container from the DOM
	$button_container.remove();

	// Reset the element to the original value
	$el
	.text( $el.data('originalValue') )
	.removeClass('active')
	.removeAttr('contenteditable')
	.attr('title', 'Click to Edit');
	
	cancelMessage();
}

function cancelOrEscapeSelect($el_parent){
	$el_parent
	.empty()
	.append('<span>' + $el_parent.data('originalValue') + '</span>')
	.removeClass('active')
	.attr('title', 'Click to select new value');
	
	cancelMessage();
}

function successMessage(){
	swal({
		type:'success',  
		text: 'Your changes have been saved',
		toast: true,
		position: 'top-end',
		showConfirmButton: false,
		timer: 3000,
	});	
}
function failMessage(msg){
/*	
	Toastr style
	swal({
		type:'error',  
		title: 'Error!',
		text: msg,
		toast: true,
		position: 'top-end',
		showConfirmButton: false,
		timer: 3000,
	});	
*/	
	// Popup style
	swal({
		type: 'error',  
		title: 'Error!',
		text: msg,
	});	
}

function cancelMessage(){
	swal({
		type:'info',  
		text: 'Changes have been cancelled',
		toast: true,
		position: 'top-end',
		showConfirmButton: false,
		timer: 3000,
	});	
}