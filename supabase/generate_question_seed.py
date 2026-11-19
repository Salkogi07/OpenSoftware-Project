"""assets/questions.json -> 수파베이스 문제 입력 SQL 만들기

사용법 (저장소 루트에서):
    python supabase/generate_question_seed.py supabase/migrations/<날짜시간>_seed_questions.sql

같은 id가 있으면 내용을 덮어쓰므로(upsert), 문제를 고친 뒤 새 파일 이름으로 다시 만들어 적용하면 됩니다.
"""
import json
import sys
from pathlib import Path


def sql_text(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def main(out_path: str) -> None:
    rows = json.loads(Path("assets/questions.json").read_text(encoding="utf-8"))
    values = []
    for q in rows:
        choices = "array[" + ", ".join(sql_text(c) for c in q["choices"]) + "]"
        values.append(
            "  ("
            + ", ".join(
                [
                    sql_text(q["id"]),
                    sql_text(q["topic"]),
                    sql_text(q["difficulty"]),
                    sql_text(q["prompt"]),
                    choices,
                    str(int(q["answer"])),
                    sql_text(q["word"]),
                    sql_text(q["meaning"]),
                    sql_text(q["explanation"]),
                ]
            )
            + ")"
        )
    sql = (
        f"-- assets/questions.json에서 자동 생성 ({len(rows)}문제). 직접 고치지 말고 스크립트로 다시 만드세요.\n"
        "insert into public.questions\n"
        "  (id, topic, difficulty, prompt, choices, answer, word, meaning, explanation)\n"
        "values\n"
        + ",\n".join(values)
        + "\non conflict (id) do update set\n"
        "  topic = excluded.topic, difficulty = excluded.difficulty, prompt = excluded.prompt,\n"
        "  choices = excluded.choices, answer = excluded.answer, word = excluded.word,\n"
        "  meaning = excluded.meaning, explanation = excluded.explanation;\n"
    )
    Path(out_path).write_text(sql, encoding="utf-8", newline="\n")
    print(f"{len(rows)}문제 -> {out_path}")


if __name__ == "__main__":
    main(sys.argv[1])
