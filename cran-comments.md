## fastVoteR 0.0.3

* Remove the `data.table` dependency => this breaks the `mlr3fselect` reverse dependency but we have already prepared an update to solve this
* Improve documentation
* Export internal R functions that wrap C++ code for easier reuse
