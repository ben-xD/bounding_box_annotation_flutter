-- TODO add authors

-- 1. CLEAR EXISTING DATA
DROP TABLE IF EXISTS Annotations;
DROP TABLE IF EXISTS AnnotationJobs;
CREATE TABLE IF NOT EXISTS AnnotationJobs (
    id text PRIMARY KEY NOT NULL,
    CreatedOn datetime NOT NULL,
    ImageFileName text NOT NULL
);

CREATE TABLE IF NOT EXISTS Annotations (
    id text PRIMARY KEY NOT NULL,
    AnnotatedOn datetime NOT NULL,
    ServerReceivedOn datetime NOT NULL,
    AnnotationJobID text NOT NULL,
    BoundingBoxes text NOT NULL,
    FOREIGN KEY (AnnotationJobID) REFERENCES AnnotationJobs(id) ON DELETE CASCADE
);
