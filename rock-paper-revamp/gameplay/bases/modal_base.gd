extends Resource
class_name ModalBase

const SHOW_IF = {
	"show_cancel_btn": ["cancel_btn_text"]
}

@export_category("Metadata")
## A unique ID for this modal
@export var modal_id: String

@export_category("Properties")
## The top bar title.
@export var title: String
## The main body of the modal. This text is larger.
@export var primary_text: String
## The secondary body of the modal. This text is slightly smaller and beneath the main body.
@export var secondary_text: String
## The text to display on the 'continue' button.
@export var continue_btn_text: String

@export_category("Flags")
## Display a cancel button.
@export var show_cancel_btn: bool = false

@export_category("Additional")
## The text to display on the 'cancel' button.
@export var cancel_btn_text: String
