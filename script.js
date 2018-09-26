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
});

function CreateInlineEditors(){	

	// Enhance tooltip title
	// $('.js-inline-editor').tooltip();

	// 'Activate' the editor on 'click'
	// $('.js-inline-editor').on('dblclick', function(e){
	$('.js-inline-editor').on('click', function(e){
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

		
		
		// toastrLoader('Saving...');

		$.post('act_save.cfm', 
		{	
			encrypted_val: $el.data('encryptedVal'),
			the_value: $el.html()
		})
		.success(function(data) {
			if(data.result){
				// 'Deactivate' the editor
				// Reset the element to the original value
				$el
				.removeClass('active')
				.removeAttr('contenteditable')
				.attr('title', 'Click to Edit');
				// remove the button container from the DOM
				$button_container.remove();
				successMessage();
			}
			else{
				failMessage(data.message);
			}
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


function cancelOrEscape($button_container, $el){
	// Reset the element to the original value
	$el
	.html( $el.data('originalValue') )
	.removeClass('active')
	.removeAttr('contenteditable')
	.attr('title', 'Click to Edit');
	
	// remove the button container from the DOM
	$button_container.remove();

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