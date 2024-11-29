# Since you're using Terraform v1.9.8, which supports 
# modern syntax, you do not need the ${} interpolation for 
# variables. You can use the cleaner and more concise syntax 
#directly:
#"Environment" = "${var.tags[0]}"
#"Owner"       = "${var.tags[1]}"

resource "" "name" {
    tags = {
        "Environment" = var.tags[0]
        "Owner"       = var.tags[1]
    }
}