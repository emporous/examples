# examples

This repo contains examples of Emporous use cases and demos.

## Structure
Each use-case is represented by a directory under repo root and should contain the structure of the  `./use-case-directory-TEMPLATE/` example below. Not all items must be present in all example use-cases.

```
~/use-case-directory-TEMPLATE$ tree
.
├── dataset-config.yaml
├── demo-content
│   ├── index.html
│   ├── site.css
│   └── site.js
├── README.md
├── schema
│   ├── schema.json
│   └── uro.bin
└── utils
    ├── script1.sh
    └── script2.sh
```

### Item descriptions:

**dataset-config.yaml** - The publishing configuration of the example collection.

**demo-content(dir)** - The content used in the demo

**README.md** - This should contain a hyperlink to the video demo, a detailed description of the example use case, a description of each resource within the use-case directory tree, and instructions on how to run the demo. 

**schema(dir)** - The attribute schema and application logic of the collection type

**utils(dir)** - Any resources used in preparation and execution of the demo. 

## Contributions

### To propose a use-case
Please propose use-cases via PR by using the `./use-case-directory-TEMPLATE` directory as a template. Fill out the use-case directory's README.md with as much information and description as possible. 

### To submit demos
Please submit demos of use-cases by PR by adhering to the use-case-directory-TEMPLATE structures. Please update the README.md of the use-case and remove any unused artifacts from the template. 


