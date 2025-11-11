# infra-s3

Dette katalogen inneholder Terraform‑konfigurasjon for å sette opp en S3‑bucket som lagrer analyseresultater. Bucketen har en egen livssyklus for midlertidige filer under prefikset `midlertidig/`, slik at slike filer kan flyttes til billigere lagringsklasse og deretter slettes automatisk. Alle andre filer blir liggende permanent.

## Forutsetninger

- Terraform ≥ 1.5.0.
- En eksisterende S3‑bucket for Terraform state, `pgr301-terraform-state`, i region `eu-west-1`.
- AWS API‑nøkler tilgjengelig enten via miljøvariabler (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`) eller konfigurert med `aws configure`.

## Variabler

 Tabellen under beskriver variablene som kan overstyres:

  | Variabel | Beskrivelse | Standardverdi |
  |---|---|---|
  | `region` | Region der ressursene opprettes. | `eu-west-1` |
  | `bucket_name` | Navn på S3‑bucketen. Navnet må være globalt unikt. | `kandidat-<nr>-data` |
  | `enable_versioning` | Slår på versjonering av objekter i bucketen. | `false` |
  | `enable_glacier_tiering` | Flytt objekter under `midlertidig/` til billigere lagringsklasse etter noen dager. | `true` |
  | `days_to_glacier` | Antall dager før overgang til billigere lagring for `midlertidig/`‑objekter. | `7` |
  | `days_to_expire` | Antall dager før sletting av `midlertidig/`‑objekter. | `30` |

## Komme i gang lokalt

1. Installer avhengigheter (Terraform og AWS CLI).
2. Initialiser Terraform med S3‑backend (bytt ut `<nr>` med kandidatnummer eller annet unikt):

   ```bash
   terraform init \
     -backend-config="bucket=pgr301-terraform-state" \
     -backend-config="region=eu-west-1" \
     -backend-config="key=kandidat-<nr>/infra-s3.tfstate"
   ```

3. Planlegg endringer (overstyr bucket‑navnet for å være sikkert på at det er unikt):

   ```bash
   TF_VAR_bucket_name="kandidat-<nr>-data" terraform plan -out=plan.tfplan
   ```

4. (Valgfritt) Apply endringene:

   ```bash
   terraform apply "plan.tfplan"
   ```

## Filoversikt

- `versions.tf` – definerer Terraform‑versjon og AWS‑provider.
- `backend.tf` – definerer backend som S3; verdier settes via `terraform init`.
- `variables.tf` – definerer variabler som kan overstyres.
- `main.tf` – oppretter S3‑bucket, offentlig tilgang blokkeres, kryptering, valgfri versjonering og livssyklus.
- `outputs.tf` – eksporterer navn, region og ID til livssyklusregelen.
- `README.md` – denne filen.