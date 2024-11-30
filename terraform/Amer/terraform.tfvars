transition = [
    {days = ["30", "90", "180", "360"]},
    {storage_class = ["STANDARD_IA", "GLACIER", "DEEP_ARCHIVE"]}
]

/*
tags        = [
   {"Environment" = ["terraformChamps"]}, 
   {"Owner" = ["Amer"]}
]
*/

/*
tags        = [
   {"Environment" = "terraformChamps"}, 
   {"Owner" = "Amer"}
]
*/

bucket_name = "ForgTech_bucket"


ingress_rules = [
  {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
