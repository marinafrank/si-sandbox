--drop table tfzgv_migration_mapping purge;
CREATE TABLE TFZGV_MIGRATION_MAPPING
( mm_guid_contract        VARCHAR2(32 CHAR) NOT NULL
, mm_old_contract_number  VARCHAR2(30 CHAR) NOT NULL
, mm_new_contract_number  VARCHAR2(30 CHAR) NOT NULL
, mm_icon_contract_type   VARCHAR2(50 CHAR)
, mm_icon_coverage        VARCHAR2(50 CHAR)
, mm_mapping_made_by      VARCHAR2(30 CHAR) NOT NULL
, mm_comment              VARCHAR2 (500 CHAR)
);
COMMENT ON TABLE tfzgv_migration_mapping IS 'Cleansing results for affected Vehicle Contracts and Extraction mapping.';

COMMENT ON COLUMN tfzgv_migration_mapping.mm_comment IS 'Mapping reason (Integrated to new contract DEF5658, renumbered DEF5660, etc.).';
COMMENT ON COLUMN tfzgv_migration_mapping.mm_mapping_made_by IS '"Cleansing" - cleansing script; "Extraction" - extraction logic.';

CREATE INDEX tfzgv_migrmap_guidcontract_i ON tfzgv_migration_mapping(mm_guid_contract);
CREATE INDEX tfzgv_migrmap_old_contrnum_i ON tfzgv_migration_mapping(mm_old_contract_number);
