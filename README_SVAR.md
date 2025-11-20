# README_SVAR

---

## Oppgave 1 – Infrastruktur (Terraform, S3, GitHub Actions)

1
Infrastruktur:

I mappen `\infra-s3` har jeg satt opp terraform til å lage og konfigurere S3-bucketen som brukes i resten av oppgavene.

- Bucket: `kandidat-28-data`
- Region: `eu-west-1`
- Terraform-versjon er låst til `terraform >= 1.5`.
- Backend: Terraform state lagres i S3-bucketen `pgr301-terraform-state`, slik at state kan deles mellom lokal kjøring og CI.

Lifecycle:

Jeg har konfigurert en lifecycle-regel som kun gjelder filer under prefixet `midlertidig/`:

- Filer under `midlertidig/` kan flyttes til en billigere lagringsklasse etter en periode (styrt av variabler).
- Filer under `midlertidig/` slettes automatisk etter X antall dager (konfigurerbart via variabler).
- Filer utenfor `midlertidig/` berøres ikke av lifecycle-regelen og blir liggende permanent.

Dette gjør at midlertidige analyseresultater rydder seg selv bort, mens permanente data fortsatt ligger trygt i samme bucket.

Variabler og outputs

For å unngå hardkoding bruker jeg Terraform-variabler for blant annet:

- bucket-navn
- region
- antall dager før overgang/sletting

Det er også definert outputs (f.eks. bucket-navn og region) slik at innstillingene kan gjenbrukes i andre deler av systemet.

CI/CD – Terraform workflow (terraform-s3.yml)

I `.github/workflows/terraform-s3.yml` har jeg satt opp en GitHub Actions-workflow som automatiserer kjøring av Terraform for `infra-s3/`:

- Trigger:
    - På `pull_request` mot `main` når filer i `infra-s3/**` (og eventuelt `.github/**`) endres.
    - På `push` til `main` med samme path-filter.

- På pull request:
    - `terraform fmt -check`
    - `terraform init`
    - `terraform validate`
    - `terraform plan`
    - Planen lastes opp som artifact, slik at den kan gjennomgås før merging.

- På push til main:
    - `terraform init`
    - `terraform validate`
    - `terraform apply -auto-approve`

AWS-tilgang settes opp via GitHub Secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION=eu-west-1`

Workflowen gjør at infrastrukturendringer alltid går gjennom samme pipeline og er sporbare i git.

Hvorfor dette er i harmoni med DevOps prinsipper (Flyt, feedback og kontinuerlig læring og forbedring)

All S3-konfigursjon skjer gjennom Terraform, slik at endringer kan spores i git, rulles tilbake ved behov og kjøres likt hver gang. Infrastruktur endres gjennom pull requests på samme måte som applikasjonskode. GitHub Actions kjører terraform fmt, validate og plan på PR, og apply når noe merges til main. Dette gir god flyt fordi endringer går automatisk fra kode til AWS uten manuell klikking, og det gir rask feedback fordi jeg ser feil og planer direkte i pipeline før noe faktisk blir endret. Lifecycle reglen på midlertidig/ sørger for at midlertidige filer først kan flyttes til billigere lagring og derreter slettes etter X antall dager. Resten av dataen ligger trygt og kostnader og rot minimeres. Bucketen er låst med Public Access lock og server-side kryptering, og AWS nøkler ligger trygt i GitHub Secrets. Drift, kost og sikkerhet er bygget inn i koden og pipelinen. som gjør det enkelt for kontinuerlig læring og forbedring fordi vi kan eksperimentere trygt, se hva som skjer i git-historikken og justere oppsettet steg for steg.

---

## Oppgave 2 – SAM, Lambda og GitHub Actions

### 2a

2a
API URL:
https://o0i4kdx650.execute-api.eu-west-1.amazonaws.com/Prod/analyze
s3 URI
s3://kandidat-28-data/midlertidig/comprehend-20251112-185610-fd432593.json

### 2b

2b
Workflow fil
https://github.com/106xayt/eksamen-2025-28/blob/main/.github/workflows/sam-deploy.yml

grønn workflow kun PR
https://github.com/106xayt/eksamen-2025-28/actions/runs/19312827774

grønn workflow push til main
https://github.com/106xayt/eksamen-2025-28/actions/runs/19318681559

---

## Oppgave 3 – Container og Docker

3b
Workflow fil
https://github.com/106xayt/eksamen-2025-28/blob/main/.github/workflows/docker-build.yml

Container navn
arstedis/sentiment-docker:latest

Build link
https://github.com/106xayt/eksamen-2025-28/actions/runs/19352734108

Workflowen bygger og publiserer imaget med to tags:

- `latest` – peker alltid på siste vellykkede build fra `main`, og brukes for enkel lokal testing.
- `sha-<commit>` – unik tag per commit (f.eks. `sha-79610aba...`).
  Dette gjør at vi alltid kan rulle tilbake til en spesifikk versjon av imaget og se nøyaktig hvilken kode som kjørte i et gitt miljø. Denne kombinasjonen gir både enkel bruk (`latest`) og sporbarhet
  (`sha-<commit>`).

Instruks til sensor
For å teste Docker-workflowen i en fork må sensor:

1. Opprette et Docker Hub-repo: `<sensor-brukernavn>/sentiment-docker` (public).
2. Legge til følgende repo-secrets i GitHub-forken:
    - `DOCKER_USERNAME` = `<sensor-brukernavn>`
    - `DOCKER_TOKEN` = Docker Hub Personal Access Token (Read & Write).
3. Sørge for at workflow-filen `.github/workflows/docker-build.yml` ligger på `main`.
4. Pushe en endring under `sentiment-docker/**` til `main`
   (eller merge en PR som endrer filer under `sentiment-docker/**`).
5. Gå til **Actions** i GitHub og verifisere at workflowen
   **“Build and push Docker image”** går grønt og publiserer et image til
   `docker.io/<sensor-brukernavn>/sentiment-docker` med taggene `latest` og `sha-<commit>`.

---

## Oppgave 4 – Observabilitet og metrics

4a

Alle metrikker ligger i samme namespace, kandidat-28, og bruker de samme taggene som candidate, company og sentiment. Det gjør det enkelt å filtrere og sammenligne før og etter endringer, og gir en ryddig base for videre forbedring uten at jeg må endre kode hver gang jeg vil se på dataene på en ny måte.

Counteren sentiment.analysis.total måler hvor mange analyser som faktisk går gjennom systemet. Den hjelper direkte på flyt, fordi jeg raskt ser om trafikken stopper opp etter en endring eller en deploy. Hvis antallet går mot null, får jeg tydelig feedback på at noe er galt, og jeg kan bruke det som startpunkt for feilsøking. Timeren sentiment.analysis.duration måler hvor lang tid Bedrock-kallet bruker. Da ser jeg om AI-delen gjør systemet tregt, og om endringer jeg gjør faktisk forbedrer eller ødelegger ytelsen. På den måten får jeg raske feedback-looper på både volum og responstid.

Gaugen sentiment.analysis.companies.detected sier noe om hvor mange selskaper modellen finner per analyse. Her er jeg ikke mest opptatt av om systemet kjører, men om tjenesten oppfører seg slik den skal. Verdien kan gå opp og ned fra kall til kall, og gir en sanntidsfølelse av hvor komplekse tekstene er og om modellen fortsatt plukker opp flere selskaper når teksten er rik. DistributionSummary for sentiment.analysis.confidence samler confidence-score over tid. Den er viktig for læring og forbedring, fordi jeg kan se om modellen blir mer eller mindre sikker på svarene sine etter endringer. Når jeg kan se utviklingen i confidence og antall selskaper over tid, blir det enklere å justere prompts, terskler eller modellvalg basert på faktiske målinger, ikke bare magefølelse.

Her vises skjermbilder av metrikker konfigurert i applikasjonen.

[CloudWatch sentiment total](media/oppgave4a-metric-sentiment-analysis-total.png)

[CloudWatch sentiment duration](media/oppgave4a-metric-sentiment-analysis-duration.png)

[CloudWatch sentiment confidence](media/oppgave4a-metric-sentiment-analysis-confidence-count.png)

[CloudWatch sentiment companies](media/oppgave4a-metric-sentiment-analysis-companies-detected.png)

4b

[Dashboard](media/oppgave4b-dashboard.png)

[Alarm](media/oppgave4b-alarm.png)

[Epost](media/oppgave4b-email.png)

## Oppgave 5 – Drøfting om KI-assistert systemutvikling

### Innledning

5

KI-assistenter som Copilot og ChatGPT kan endre hvordan vi skriver kode, konfigurerer infrastruktur og lager dokumentasjon.

I et DevOps-perspektiv påvirker dette både flyt, feedback og kontinuerlig læring. Jeg mener verktøyene kan gi stor gevinst, men bare hvis teamet er bevisst på nye risikoer og bygger kontroll rundt dem. På den positive siden kan KI øke hastigheten kraftig. Oppgaver som å skrive boilerplate-kode, YAML til GitHub Actions eller Terraform-resurser går mye raskere når verktøyet foreslår et førsteutkast. I denne eksamenen kunne jeg for eksempel bruke KI til å generere en start på en workflow eller en Spring-controller, og heller bruke tiden på å forstå arkitektur og krav.

### Hoveddel

Samtidig kan KI skape nye flaskehalser. Forslagene kan se riktige ut, men inneholde små feil i navn, versjoner eller sikkerhetsinnstillinger. Da flyttes flaskehalsen fra til å debugge småfeil som kan bli vanskelige å finne hvis man ikke forstår koden godt nok. Code review kan også bli tyngre hvis revieweren ikke vet hvilke deler som er KI-generert. KI-generert kode ser ofte ryddig og pent ut, og dermed kan det være lett å skumme seg gjennom feil i f.eks. logikk, sikkerhet eller ytelse. KI øker hastigheten raskt i starten, men det kan være overflødig hvis man ikke vet hvordan det skal brukes, ettersom jo nærmere man kommer deploy, kan det komme flere problemer å debugge enn nødvendig.

Når det gjelder feedback-loops, mener jeg det viktigste er at utvikler/team skal stå for kvaliteten, og ikke la KI bestemme hva som er godt nok. Når koden er delvis generert av KI, er det viktig at automatiserte tester og overvåkning er på plass. Tester må fange opp feil som kanskje ikke blir oppfattet ved første øyekast, og dashboards og metrikker må fortelle hvordan systemet oppfører seg etter enhver endring.

Feedback-loops bør justeres i prosessen, slik at problemer kan oppdages tidlig. Utvikler kan f.eks. kreve at koden kjøres gjennom ekstra tester, eller manuelt se gjennom sensitive områder. Slik unngår man at feedback-loopen er kort. KI kan fortsatt forbedre feedback, f.eks. gjennom å tolke feilmeldinger eller foreslå alt fra tester, metrics eller alarmer.

Det er klart at ved å generere full og ferdig kode kan KI svekke dybdekompetansen i nye utviklere, men KI kan fortsatt være et sterkt læringsverktøy. Konsepter som er vanskelige å forstå eller vanskelige å finne informasjon om kan forklares i dybden med kun en prompt. I eksamensoppgaven kunne KI f.eks. gitt en trinn-for-trinn-forklaring på hvordan en GitHub Actions-workflow henger sammen med bygg, test og deploy, eller be om hjelp til å forstå hva en feilet pipeline egentlig klager på. Samtidig er det fare for at uviklere blir passive med prompts i stedet for å bruke KI til å bygge dybdeforståelse. Hvis en utvikler alltid ber om en ferdig fil, uten å følge opp med krav til f.eks. arkitektur, sikkerhet eller til og med noe så lite som variabelnavn, kan  debugging og forbedringer bli problematisk i lengden. Dette vil direkte svekke kompetanse i utvikleren.

For å unngå dette må læring rundt KI-bruk være aktivt i organisasjoner og team. Dette kan være diskusjon rundt formulering av prompts eller bygge nye ferdigheter når det gjelder bruk av KI. Utvikleren må kunne kjenne igjen farlige løsninger og validere forslag kritisk.

### Konklusjon

KI-assistert utvikling kan styrke DevOps-prinsippene hvis den brukes bevisst. Det kan skape raskere flyt ved å kutte ut unødvendig manuelt arbeid, gi bedre feedback gjennom sterkere tester, og mer læring forklaringer og eksempler av komplekse konsepter. Samtidig kan KI også skade flyt, skjule feil og svekke kompetanse hvis utviklere og team godtar løsninger fra KI blindt. Utviklere er nødt til å bruke KI som en hjelpende hånd, ikke en delegert arbeider. Utvikleren må fortsatt stå for designvalg, kvalitet og sikkerhet for det som går i produksjon.
