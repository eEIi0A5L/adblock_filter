test:
	./scripts/fmt.sh
	./scripts/js.sh
	./scripts/check_merge.sh

fmt:
	./scripts/fmt.sh

maint:
	./scripts/maint.sh

dup:
	./scripts/dup.sh

ast:
	./scripts/ast.sh

domain:
	./scripts/domain.sh

cd:
	./scripts/cd.sh

count:
	./scripts/count.sh

cm:
	./scripts/cm.sh

ic:
	./scripts/ic.sh
