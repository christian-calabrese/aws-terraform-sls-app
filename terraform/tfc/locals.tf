################################################################################
# description of the common variables for all workspaces
################################################################################
locals {
  functions = [
    {
      name        = "create-note"
      handler     = "create_note.lambda_handler"
      runtime     = "python3.11"
      environment = {}
      http_method = "POST"
      path_part   = "notes"
    },
    {
      name        = "get-notes"
      handler     = "get_notes.lambda_handler"
      runtime     = "python3.11"
      environment = {}
      http_method = "GET"
      path_part   = "notes"
    },
    {
      name        = "get-note"
      handler     = "get_note.lambda_handler"
      runtime     = "python3.11"
      environment = {}
      http_method = "GET"
      path_part   = "notes/{note_id}"
    },
    {
      name        = "delete-note"
      handler     = "delete_note.lambda_handler"
      runtime     = "python3.11"
      environment = {}
      http_method = "DELETE"
      path_part   = "notes/{note_id}"
    }
  ]
}
