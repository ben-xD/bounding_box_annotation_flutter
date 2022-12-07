-- TODO add authors

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
    FOREIGN KEY (AnnotationJobID) REFERENCES AnnotationJobs(id)
);

-- ADD DATA
-- INSERT INTO Annotations (author, body, post_slug) VALUES ("Kristian", "Great post!", "hello-world");

INSERT INTO AnnotationJobs (id, CreatedOn, ImageFileName) VALUES ("892461f6-b00a-469f-9fd1-42c71bc0fe00", '20221206 10:00:00', "rodrigo-dos-reis-DkTuGvgPotA-unsplash.jpg");
INSERT INTO AnnotationJobs (id, CreatedOn, ImageFileName) VALUES ("ce52db24-aa55-45c2-bf1a-4c93b3c0eb61", '20221206 11:00:00', "eiliv-aceron-k9X5yGle-NA-unsplash.jpg");
INSERT INTO AnnotationJobs (id, CreatedOn, ImageFileName) VALUES ("5be43825-9ae9-457f-82e6-b32fdc7531f7", '20221206 12:00:00', "IMG_4004.jpg");


INSERT INTO Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) VALUES (
    "3ed3397f-6a7d-4cb3-a260-f935151dc95b", "20221207 10:00:00", "20221207 10:05:00", "892461f6-b00a-469f-9fd1-42c71bc0fe00", "[]"
);
INSERT INTO Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) VALUES (
    "ef74f94d-f1b6-470d-acb2-a456063fa79b", "20221207 10:00:00", "20221207 10:05:00", "892461f6-b00a-469f-9fd1-42c71bc0fe00", "[]"
);
