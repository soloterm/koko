//! Locate eSpeak data before the phonemizer can initialize with an unusable default.

use std::env;
use std::path::{Path, PathBuf};

const PIPER_DATA_DIRECTORY: &str = "PIPER_ESPEAKNG_DATA_DIRECTORY";
const ESPEAK_DATA_PATH: &str = "ESPEAK_DATA_PATH";

fn data_dir(parent: &Path) -> PathBuf {
    parent.join("espeak-ng-data")
}

fn has_phontab(data: &Path) -> bool {
    data.join("phontab").is_file()
}

pub fn init() -> Result<(), String> {
    if let Some(parent) = env::var_os(PIPER_DATA_DIRECTORY) {
        let parent = PathBuf::from(parent);
        let data = data_dir(&parent);
        if has_phontab(&data) {
            return Ok(());
        }
        return Err(format!(
            "eSpeak data not found: {PIPER_DATA_DIRECTORY}={} requires {} (set it to the parent of espeak-ng-data)",
            parent.display(),
            data.join("phontab").display()
        ));
    }

    if let Some(path) = env::var_os(ESPEAK_DATA_PATH) {
        let path = PathBuf::from(path);
        let data = if has_phontab(&path) {
            path.clone()
        } else {
            data_dir(&path)
        };
        if has_phontab(&data) {
            let parent = data.parent().ok_or_else(|| {
                format!("eSpeak data directory has no parent: {}", data.display())
            })?;
            env::set_var(PIPER_DATA_DIRECTORY, parent);
            return Ok(());
        }
        return Err(format!(
            "eSpeak data not found: {ESPEAK_DATA_PATH}={} requires {} or {}",
            path.display(),
            path.join("phontab").display(),
            data.join("phontab").display()
        ));
    }

    let executable = env::current_exe()
        .and_then(|path| path.canonicalize())
        .map_err(|error| {
            format!("Cannot locate eSpeak data: canonicalizing current executable failed: {error}")
        })?;
    let executable_dir = executable.parent().ok_or_else(|| {
        format!(
            "Cannot locate parent of executable: {}",
            executable.display()
        )
    })?;
    let mut parents = vec![executable_dir.to_path_buf()];

    if let Ok(cwd) = env::current_dir() {
        if cwd != executable_dir {
            parents.push(cwd);
        }
    }

    #[cfg(target_os = "linux")]
    parents.extend([
        PathBuf::from("/usr/share"),
        PathBuf::from("/usr/local/share"),
    ]);

    for parent in &parents {
        if has_phontab(&data_dir(parent)) {
            env::set_var(PIPER_DATA_DIRECTORY, parent);
            return Ok(());
        }
    }

    let paths = parents
        .iter()
        .map(|parent| data_dir(parent).join("phontab").display().to_string())
        .collect::<Vec<_>>()
        .join(", ");
    Err(format!(
        "eSpeak data not found: tried {paths}. Place espeak-ng-data beside koko or set {PIPER_DATA_DIRECTORY} to its parent."
    ))
}
