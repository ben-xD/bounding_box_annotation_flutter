-- TODO add authors

DROP TABLE IF EXISTS Annotations;
DROP TABLE IF EXISTS AnnotationJobs;
CREATE TABLE IF NOT EXISTS AnnotationJobs (
    id text PRIMARY KEY NOT NULL,
    CreatedOn datetime NOT NULL,
    ImageURL text NOT NULL
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

INSERT INTO AnnotationJobs (id, CreatedOn, ImageURL) VALUES ("892461f6-b00a-469f-9fd1-42c71bc0fe00", '20221206 10:00:00', "https://kagi.com/proxy/holiday-fruit-basket.jpg?c=if02fW-Pkfi0hX7oacQJlRwWktkVGivq6FK_P5NPqaz3R9DWapQJuK20hhsnYxvyetQWS7lLIBj-tmuXxlxUaz6i0xjhwzI4eYKorbSDznZBVI9mQC2Hy7ZmyzI8wqMd");
INSERT INTO AnnotationJobs (id, CreatedOn, ImageURL) VALUES ("ce52db24-aa55-45c2-bf1a-4c93b3c0eb61", '20221206 11:00:00', "https://kagi.com/proxy/th?c=MvlWCDdicm1aK3zpADFz51uffrI0FEB-kI9GN5Oyn_c519eEgKnFEnwIaf59q6DBtTNUcjdiqwfggDbUwk8ZOP26r5Zi7dWD6CkW5XpSn6yiYwYEloKXvffuHveH9NyT");
INSERT INTO AnnotationJobs (id, CreatedOn, ImageURL) VALUES ("5be43825-9ae9-457f-82e6-b32fdc7531f7", '20221206 12:00:00', "https://kagi.com/proxy/1cxq8vwf4yt31.jpg?c=TklOzPjLPioJ5YMJT75bSg-sbyU-vsc6Ll8hfSuJcS5M2a_mQ6LNkii4Y2Um1Fx6");


INSERT INTO Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) VALUES (
    "3ed3397f-6a7d-4cb3-a260-f935151dc95b", "20221207 10:00:00", "20221207 10:05:00", "892461f6-b00a-469f-9fd1-42c71bc0fe00", "[]"
);
INSERT INTO Annotations (id, AnnotatedOn, ServerReceivedOn, AnnotationJobID, BoundingBoxes) VALUES (
    "ef74f94d-f1b6-470d-acb2-a456063fa79b", "20221207 10:00:00", "20221207 10:05:00", "892461f6-b00a-469f-9fd1-42c71bc0fe00", "[]"
);
