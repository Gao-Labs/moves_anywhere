# Figure

## Blueprint System Architecture for a Scientific Computing System

*Caption*: Icons show User Actions. Buttons show internal functions that are performed, required by, enabled, or used
by the subsequent action or function.

```mermaid
---
config:
  look: neo
  layout: dagre
---
flowchart LR
 subgraph subGraph0["Container Functions"]
        f1(["Containerized<br>Software<br>as Image"])
        f2(["Run Container<br>as Job<br>from Image"])
        f3(["Mount Bucket<br>to Container"])
  end
 subgraph subGraph2["Cloud Job Functions"]
        f7(["Trigger Job"])
  end
 subgraph subGraph00["Distributed Job Functions"]
        subGraph0
        subGraph2
  end
 subgraph subGraph1["Cloud Bucket Functions"]
        f4(["Add Inputs<br>to Bucket"])
        f5(["Extract Outputs<br>from Bucket"])
        f6(["Create<br>Bucket"])
        f8(["List Contents<br>from Bucket"])
        f11(["Delete Bucket"])
  end
 subgraph subGraph3["Account Functions"]
        f12(["Create User ID"])
        f13(["Delete User ID"])
        f10(["Get User ID"])
  end
 subgraph subGraph4["User Basic Actions"]
        ff1(["Order Add"])
        ff2(["Order Get"])
        ff4(["Order Delete"])
  end
 subgraph subGraph5["User Account Actions"]
        ff5(["Account Create"])
        ff6(["Account Delete"])
        ff7(["Account Login"])
  end
    ff1 -- performs --> f7 & f6 & f4
    ff6 -- performs --> f13
    ff5 -- performs --> f12
    f7 -- performs --> f2
    ff2 -- requires --> f8
    ff2 -- performs --> f5
    f2 -- performs --> f3
    f2 -- requires --> f1
    ff7 -- performs --> f10
    ff4 -- performs --> f11
    f10 -- used by --> ff1 & ff2
    f4 -- enables --> f3
    f6 -- enables --> f4 & f8 & f11 & f5
    f5 -- requires --> f3
    ff1@{ icon: "fa:pen-to-square", pos: "b"}
    ff2@{ icon: "fa:hard-drive", pos: "b"}
    ff4@{ icon: "fa:trash-can", pos: "b"}
    ff5@{ icon: "fa:circle-check", pos: "b"}
    ff6@{ icon: "fa:circle-xmark", pos: "b"}
    ff7@{ icon: "fa-circle-user", pos: "b"}
    style subGraph0 fill:#648FFF66
    style subGraph2 fill:#648FFF66
    style ff1 stroke:#FFFFFF
    style ff2 stroke:#FFFFFF
    style ff4 stroke:#FFFFFF
    style ff5 stroke:#FFFFFF,fill:transparent
    style ff6 stroke:#FFFFFF
    style ff7 stroke:#FFFFFF
    style subGraph5 fill:#FE6100
    style subGraph3 fill:#FE610066
    style subGraph4 fill:#648FFF
    style subGraph00 fill:#FFFFFF
    style subGraph1 fill:#FFB000
```
